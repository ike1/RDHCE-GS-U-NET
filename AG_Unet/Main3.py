# This main uses callbacks for early stopping

# Importing libraries
from Class_2 import unet_original   #Use normal unet model

from keras.utils import normalize
import os
import cv2
from PIL import Image
import numpy as np
from matplotlib import pyplot as plt
import tensorflow as tf
import csv
from keras.models import load_model


# Image path
image_directory = r'D:\Codes Unet\images\\'
mask_directory = r'C:\Users\NUIST-PC28\Downloads\VGG-Image-Annotator\mask\\'


model_unet_mine = load_model(r'D:\Codes\UNet_Original\unet_original_EP200.keras')
#y_pred = model_unet_mine.predict(X_test)
SIZE = 256
image_dataset = []  #Many ways to handle data, you can use pandas. Here, we are using a list format.  
mask_dataset = []  #Place holders to define add labels. We will add 0 to all parasitized images and 1 to uninfected.

images = os.listdir(image_directory)
for i, image_name in enumerate(images):    #Remember enumerate method adds a counter and returns the enumerate object
    if (image_name.split('.')[1] == 'png'):
        #print(image_directory+image_name)
        image = cv2.imread(image_directory+image_name, 0)
        image = Image.fromarray(image)
        image = image.resize((SIZE, SIZE))
        image_dataset.append(np.array(image))

#Iterate through all images in Uninfected folder, resize to 64 x 64
#Then save into the same numpy array 'dataset' but with label 1

masks = os.listdir(mask_directory)
for i, image_name in enumerate(masks):
    if (image_name.split('.')[1] == 'png'):
        image = cv2.imread(mask_directory+image_name, 0)
        image = Image.fromarray(image)
        image = image.resize((SIZE, SIZE))
        mask_dataset.append(np.array(image))


#Normalize images
image_dataset = np.expand_dims(normalize(np.array(image_dataset), axis=1),3)
#D not normalize masks, just rescale to 0 to 1.
mask_dataset = 1.0-(np.expand_dims((np.array(mask_dataset)),3) /255.)


from sklearn.model_selection import train_test_split

# First split: Create training and test sets
X_train, X_test, y_train, y_test = train_test_split(image_dataset, mask_dataset, test_size = 0.10, random_state = 0)

# Second split: Further split the training set into training and validation sets
X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.20, random_state=0)  # 20% of training data for validation

# Quick test subset (if needed, separate from the main train-validation split)
#X_train_quick_test, X_test_quick_test, y_train_quick_test, y_test_quick_test = train_test_split(X_train, y_train, test_size = 0.9, random_state = 0)
X_train_quick_test, X_test_quick_test, y_train_quick_test, y_test_quick_test = train_test_split(X_train, y_train, test_size=0.9, random_state=0)

#Sanity check, view few mages
import random
import numpy as np
image_number = random.randint(0, len(X_train))
plt.figure(figsize=(12, 6))
plt.subplot(121)
plt.imshow(np.reshape(X_train[image_number], (256, 256)), cmap='gray')
plt.subplot(122)
plt.imshow(np.reshape(y_train[image_number], (256, 256)), cmap='gray')
plt.show()

###############################################################
IMG_HEIGHT = image_dataset.shape[1]
IMG_WIDTH  = image_dataset.shape[2]
IMG_CHANNELS = image_dataset.shape[3]

def get_unet_original_model():
    return unet_original(IMG_HEIGHT, IMG_WIDTH, IMG_CHANNELS)

model_unet_original_ = get_unet_original_model()


#####################################################
# Define custom metrics
def dice_score(y_true, y_pred):
    # Convert tensors to float32
    y_true_f = tf.cast(tf.keras.backend.flatten(y_true), tf.float32)
    y_pred_f = tf.cast(tf.keras.backend.flatten(y_pred), tf.float32)
    intersection = tf.keras.backend.sum(y_true_f * y_pred_f)
    return (2. * intersection + 1e-7) / (tf.keras.backend.sum(y_true_f) + tf.keras.backend.sum(y_pred_f) + 1e-7)

def iou(y_true, y_pred):
    # Convert tensors to float32
    y_true_f = tf.cast(tf.keras.backend.flatten(y_true), tf.float32)
    y_pred_f = tf.cast(tf.keras.backend.flatten(y_pred), tf.float32)
    intersection = tf.keras.backend.sum(y_true_f * y_pred_f)
    union = tf.keras.backend.sum(y_true_f) + tf.keras.backend.sum(y_pred_f) - intersection
    return (intersection + 1e-7) / (union + 1e-7)

def precision(y_true, y_pred):
    # Convert tensors to float32
    y_true_f = tf.cast(tf.keras.backend.flatten(y_true), tf.float32)
    y_pred_f = tf.cast(tf.keras.backend.flatten(y_pred), tf.float32)
    true_positives = tf.keras.backend.sum(y_true_f * y_pred_f)
    predicted_positives = tf.keras.backend.sum(y_pred_f)
    return (true_positives + 1e-7) / (predicted_positives + 1e-7)

def recall(y_true, y_pred):
    # Convert tensors to float32
    y_true_f = tf.cast(tf.keras.backend.flatten(y_true), tf.float32)
    y_pred_f = tf.cast(tf.keras.backend.flatten(y_pred), tf.float32)
    true_positives = tf.keras.backend.sum(y_true_f * y_pred_f)
    possible_positives = tf.keras.backend.sum(y_true_f)
    return (true_positives + 1e-7) / (possible_positives + 1e-7)


##################################################
#ModelCheckpoint callback saves a model at some interval. 
filepath="saved_models/weights-improvement-{epoch:02d}-{val_jacard_coef:.2f}.keras" #File name includes epoch and validation accuracy.
#Use Mode = max for accuracy and min for loss. 


# checkpoint = ModelCheckpoint(filepath, monitor='val_jacard_coef', verbose=1, save_best_only=True, mode='max')


#https://www.tensorflow.org/api_docs/python/tf/keras/callbacks/EarlyStopping

# early_stop = EarlyStopping(monitor='val_loss', patience=3, verbose=1)


#This callback will stop the training when there is no improvement in
# the validation loss for three consecutive epochs.

#CSVLogger logs epoch, acc, loss, val_acc, val_loss
#log_csv = CSVLogger('my_logs.csv', separator=',', append=False)

# Custom CSVLogger to log additional metrics
class CustomMetricsCSVLogger(tf.keras.callbacks.Callback):
    def __init__(self, X_val, y_val, csv_file):
        self.X_val = X_val
        self.y_val = y_val
        self.csv_file = csv_file
        super().__init__()

    def on_train_begin(self, logs=None):
        # Initialize the CSV file with headers
        with open(self.csv_file, mode='w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(['epoch', 'loss', 'jacard_coef', 'val_loss', 'val_jacard_coef', 'dice', 'iou', 'precision', 'recall', 'accuracy'])

    def on_epoch_end(self, epoch, logs=None):
        val_preds = self.model.predict(self.X_val)
        
        # Compute additional metrics
        dice = dice_score(self.y_val, val_preds).numpy()
        iou_score = iou(self.y_val, val_preds).numpy()
        prec = precision(self.y_val, val_preds).numpy()
        rec = recall(self.y_val, val_preds).numpy()
        acc_score = tf.keras.metrics.binary_accuracy(self.y_val, val_preds).numpy().mean()



        # Append metrics to CSV
        with open(self.csv_file, mode='a', newline='') as file:
            writer = csv.writer(file)
            writer.writerow([
                epoch + 1,
                logs.get('loss'),
                logs.get('jacard_coef'),
                logs.get('val_loss'),
                logs.get('val_jacard_coef'),
                dice,
                iou_score,
                prec,
                rec,
                acc_score
            ])


# log_csv = CustomMetricsCSVLogger('my_logs.csv')
log_csv = CustomMetricsCSVLogger(X_val=X_val, y_val=y_val, csv_file='my_logs.csv')

# callbacks_list = [checkpoint, early_stop, log_csv]
callbacks_list = [log_csv]

#####################################

#If starting with pre-trained weights. 
#model.load_weights('mitochondria_with_jacard_50_epochs.hdf5')

# Using model.fit on X_train instead of X_train_quick
history_unet_original_quick_ = model_unet_original_.fit(X_train, y_train, 
                    batch_size = 16, 
                    verbose=1, 
                    epochs=50, 
                    validation_data=(X_test, y_test), 
                    shuffle=False,
                    callbacks=callbacks_list)
   

# Using model.fit on X_train_quick instead of X_train
 

# model_unet_original_.save('model_unet_original__EP150_jaccard.keras')

model_unet_original_.save('model_unet_original__EP150_jaccardxx.keras')

model_pathxx = 'model_unet_original__EP150_jaccardxx.keras'
model_unet_JACIEP150 = tf.keras.models.load_model(model_pathxx, compile=False)

 #####################################################################
 # Predicting using the model loaded for test
import random
test_img_number = random.randint(0, X_test.shape[0]-1)
test_img = X_test[test_img_number]
ground_truth=y_test[test_img_number]

test_img_input=np.expand_dims(test_img, 0)
prediction = (model_unet_JACIEP150.predict(test_img_input)[0,:,:,0] > 0.5).astype(np.uint8)

plt.figure(figsize=(16, 8))
plt.subplot(231)
plt.title('Testing Image')
plt.imshow(test_img, cmap='gray')
plt.subplot(232)
plt.title('Testing Label')
plt.imshow(ground_truth[:,:,0], cmap='gray')
plt.subplot(233)
plt.title('Prediction on test image')
plt.imshow(prediction, cmap='gray')

plt.show()



###############################################################
# Testing with images from test folder
#Teting only works for 512 x 512 images
test_img_other = cv2.imread(r'D:\Codes Unet\images\6.png', 0)
ground_truth = cv2.imread(r'C:\Users\NUIST-PC28\Downloads\VGG-Image-Annotator\mask\6.png', 0)
test_img_other_norm = np.expand_dims(normalize(np.array(test_img_other), axis=1),2)
test_img_other_norm=test_img_other_norm[:,:,0][:,:,None]
test_img_other_input=np.expand_dims(test_img_other_norm, 0)
#Predict and threshold for values above 0.5 probability
prediction_other = (model_unet_JACIEP150.predict(test_img_other_input)[0,:,:,0] > 0.5).astype(np.uint8)

# Plotting prediction
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Display the first image
axes[0].imshow(np.squeeze(test_img_other), cmap='gray')
axes[0].set_title('Input Image')
axes[0].axis('off')  # Hide axes

# Display the second image
axes[1].imshow(np.squeeze(ground_truth), cmap='gray')
axes[1].set_title('Ground Truth')
axes[1].axis('off')  # Hide axes

# Display the third image
axes[2].imshow(np.squeeze(prediction_other), cmap='gray')
axes[2].set_title('Predicted')
axes[2].axis('off')  # Hide axes

# Adjust layout to prevent overlap
plt.tight_layout()
# Show the figure
plt.show()



####################################################
# Resolving image not showing due to data type
# Ensure the variables are NumPy arrays
test_img_other = np.array(test_img_other)
ground_truth = np.array(ground_truth)
prediction_other = np.array(prediction_other)

# Check the data types
print(test_img_other.dtype)
print(ground_truth.dtype)
print(prediction_other.dtype)

# Convert to float32 if they are not already
test_img_other = test_img_other.astype(np.float32)
ground_truth = ground_truth.astype(np.float32)
prediction_other = prediction_other.astype(np.float32)


ground_truth = np.array(ground_truth)

# Remove singleton dimensions if present
if ground_truth.ndim == 3 and ground_truth.shape[2] == 1:
    ground_truth = np.squeeze(ground_truth)
elif ground_truth.ndim == 3 and ground_truth.shape[2] > 1:
    ground_truth = ground_truth[:, :, 0]  # Use the first channel


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Display the first image
axes[0].imshow(np.squeeze(test_img_other), cmap='gray')
axes[0].set_title('Input Image')
axes[0].axis('off')  # Hide axes

# Display the second image
#axes[1].imshow(np.squeeze(ground_truth), cmap='gray')
axes[1].imshow(np.squeeze(ground_truth), cmap='gray')
axes[1].set_title('Ground Truth')
axes[1].axis('off')  # Hide axes

# Display the third image
axes[2].imshow(np.squeeze(prediction_other), cmap='gray')
axes[2].set_title('Predicted')
axes[2].axis('off')  # Hide axes

# Adjust layout to prevent overlap
plt.tight_layout()
# Show the figure
plt.show()


#To be compared with trained model mitochondria_gpu_tf1.4.hdf5
# that just used cross entropy for loss and accuracy for metric. 

############################################################
#Evaluate the model


# evaluate model
results = model_unet_original_.evaluate(X_test, y_test)
acc = results[1]  # assuming accuracy is second item
print("Accuracy is = ", acc * 100.0, "%")


#plot the training and validation accuracy and loss at each epoch
loss = history_unet_original_quick_.history['loss']
val_loss = history_unet_original_quick_.history['val_loss']
epochs = range(1, len(loss) + 1)
plt.plot(epochs, loss, 'y', label='Training loss')
plt.plot(epochs, val_loss, 'r', label='Validation loss')
plt.title('Training and validation loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.show()


###
#plot the training and validation accuracy and loss at each epoch
loss = history_unet_original_quick_.history['jacard_coef']
val_loss = history_unet_original_quick_.history['val_jacard_coef']
epochs = range(1, len(loss) + 1)
plt.plot(epochs, loss, 'y', label='Training loss')
plt.plot(epochs, val_loss, 'r', label='Validation loss')
plt.title('Training and validation loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.show()


#########################
# ploting for histor quick


#plot the training and validation accuracy and loss at each epoch
loss = history_unet_original_quick_.history['loss']
val_loss = history_unet_original_quick_.history['val_loss']
epochs = range(1, len(loss) + 1)
plt.plot(epochs, loss, 'y', label='Training loss')
plt.plot(epochs, val_loss, 'r', label='Validation loss')
plt.title('Training and validation loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.show()


###
#plot the training and validation accuracy and loss at each epoch
loss = history_unet_original_quick_.history['accuracy']
val_loss = history_unet_original_quick_.history['val_accuracy']
epochs = range(1, len(loss) + 1)
plt.plot(epochs, loss, 'y', label='Training loss')
plt.plot(epochs, val_loss, 'r', label='Validation loss')
plt.title('Training and validation loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')
plt.legend()
plt.show()

##################################

# Model training
# Model testing is done by randomly picking images from the training set, validation set, and the test set
# and then test the model on these images

# This generates a number from 0 to the length of the folder (ie. number of images) to randomly pick an image
idx = random.randint(0, len(X_train))

# Making predictions with the model. model.predict also has its variables like model.fit
# You can read the documentation
preds_train = model_unet_original_.predict(X_train[:int(X_train.shape[0]*0.9)], verbose=1)
preds_val = model_unet_original_.predict(X_train[int(X_train.shape[0]*0.9):], verbose=1)
preds_test = model_unet_original_.predict(X_test, verbose=1)

# NB: After running the UNet model, the result from deep learning for represnt
# pixels in probablity values (ie. between 0 to 1)
# We then covert those > 0.5 to 1. preds_train is the actual predicted image where pixels are > 0.5
# same as validation and testing. The thresholding (>) meanings you are confident pixels > 0.5 are cells
# In your area, they could mean the focal region. If not > 0.5, then we 
preds_train_t = (preds_train > 0.5).astype(np.uint8)
preds_val_t = (preds_val > 0.5).astype(np.uint8)
preds_test_t = (preds_test > 0.5).astype(np.uint8)

# Plotting prediction
import matplotlib.pyplot as plt
ix = random.randint(0, len(preds_train_t))
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Display the first image
axes[0].imshow(np.reshape(X_train[ix], (256, 256)), cmap='gray')
axes[0].set_title('Input Image')
axes[0].axis('off')  # Hide axes

# Display the second image
axes[1].imshow(np.reshape(y_train[ix], (256, 256)), cmap='gray')
axes[1].set_title('Ground Truth')
axes[1].axis('off')  # Hide axes

# Display the third image
axes[2].imshow(np.squeeze(preds_train_t[ix]))
axes[2].set_title('Predicted')
axes[2].axis('off')  # Hide axes

# Adjust layout to prevent overlap
plt.tight_layout()
# Show the figure
plt.show()


# Plotting prediction
import matplotlib.pyplot as plt
ix = random.randint(0, len(preds_train_t))
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Display the first image
axes[0].imshow(np.reshape(X_train[ix], (256, 256)), cmap='gray')
axes[0].set_title('Input Image')
axes[0].axis('off')  # Hide axes

# Display the second image
axes[1].imshow(np.reshape(y_train[ix], (256, 256)), cmap='gray')
axes[1].set_title('Ground Truth')
axes[1].axis('off')  # Hide axes

# Display the third image
axes[2].imshow(np.reshape(preds_train_t[ix], (256, 256)), cmap='gray')
axes[2].set_title('Predicted')
axes[2].axis('off')  # Hide axes

# Adjust layout to prevent overlap
plt.tight_layout()
# Show the figure
plt.show()



#################################################

# 
# model = model_jacard  #Assign model to one of the models instead of changing the entire code for testing. 
#model = model_standard  #Assign model to one of the models instead of changing the entire code for testing. 

#IOU
y_pred=model_unet_mine.predict(X_test)
y_pred_thresholded = y_pred > 0.5

intersection = np.logical_and(y_test, y_pred_thresholded)
union = np.logical_or(y_test, y_pred_thresholded)
iou_score = np.sum(intersection) / np.sum(union)
print("IoU socre is: ", iou_score)

#######################################################################
#Predict on a few images
#model = get_model()
#model.load_weights('mitochondria_with_jacard_50_plus_50_epochs.hdf5') #Trained for 50 epochs and then additional 100
#model.load_weights('mitochondria_gpu_tf1.4.hdf5')  #Trained for 50 epochs

test_img_number = random.randint(0, len(X_test))
test_img = X_test[test_img_number]
ground_truth=y_test[test_img_number]
test_img_norm=test_img[:,:,0][:,:,None]
test_img_input=np.expand_dims(test_img_norm, 0)
prediction = (model_unet_mine.predict(test_img_input)[0,:,:,0] > 0.5).astype(np.uint8)

test_img_other = cv2.imread(r'D:\Codes Unet\images\10.jpg', 0)
ground_truth = cv2.imread(r'C:\Users\NUIST-PC28\Downloads\VGG-Image-Annotator\mask\10.jpg', 0)
test_img_other_norm = np.expand_dims(normalize(np.array(test_img_other), axis=1),2)
test_img_other_norm=test_img_other_norm[:,:,0][:,:,None]
test_img_other_input=np.expand_dims(test_img_other_norm, 0)
#Predict and threshold for values above 0.5 probability
prediction_other = (model_unet_mine.predict(test_img_other_input)[0,:,:,0] > 0.5).astype(np.uint8)

# Plotting prediction
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Display the first image
axes[0].imshow(np.squeeze(test_img_other))
axes[0].set_title('Input Image')
axes[0].axis('off')  # Hide axes

# Display the second image
axes[1].imshow(np.squeeze(ground_truth))
axes[1].set_title('Ground Truth')
axes[1].axis('off')  # Hide axes

# Display the third image
axes[2].imshow(np.squeeze(prediction_other))
axes[2].set_title('Predicted')
axes[2].axis('off')  # Hide axes

# Adjust layout to prevent overlap
plt.tight_layout()
# Show the figure
plt.show()


#plt.imsave('input.jpg', test_img[:,:,0], cmap='gray')
plt.imsave(r'C:\Users\NUIST-PC28\Downloads\VGG-Image-Annotator\output\output2.jpg', prediction_other, cmap='gray')










