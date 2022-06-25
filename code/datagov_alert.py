import requests
import pandas as pd
import re
# https://info.data.gov.il/datagov/home/
# https://data.gov.il/dataset

### create a function to get the data from the data.gov.il/dataset
### and return the data in a pandas dataframe
def get_data(url):
    # get the data from data.gov.il
    response = requests.get(url)
    # convert the data to a pandas dataframe
    data = response.text
    # data = pd.read_json(response.text)
    return data

data = get_data('https://data.gov.il/dataset/?page=2')
data = get_data('https://data.gov.il/dataset')

### find url addresses in the html text
def find_url(text):
    # find the url addresses in the html text
    url = re.findall('http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+', text)
    return url

url = find_url(data)

# create butterworth filter using input of sampling rate, low and high frequencies
def butter_bandpass(lowcut, highcut, fs, order=5):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    b, a = butter(order, [low, high], btype='band')
    return b, a

# import model VGG16
import keras
from keras.applications.vgg16 import VGG16
# preprocess image before VGG16
def preprocess_input(x):
    x /= 255.
    x -= 0.5
    x *= 2.
    return x
# use VGG16 model to search for houses in pictures
def vgg16_search(image_path):
    # load the model
    model = VGG16()
    # load the image
    img = image.load_img(image_path, target_size=(224, 224))
    # convert the image to a numpy array
    x = image.img_to_array(img)
    # expand the dimensions of the array
    x = np.expand_dims(x, axis=0)
    # preprocess the image
    x = preprocess_input(x)
    # make a prediction
    preds = model.predict(x)
    # return the prediction
    return preds

# create deepdream image of a cat using caffe model
def deepdream(image_path):
