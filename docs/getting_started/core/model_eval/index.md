## Who this is for
This page is for those new to FiftyOne looking to get started with model evaluation! We will cover how to load, visualize, analyze, and evaluate our model predictions. 

Perfect for any level of computer vision engineer, by the end of the tutorial, you will be able to quickly evaluate your model no matter what type or format.

## Assumed Knowledge
We will start with the assumption that you are familiar with the basic FiftyOne (dataset structure)[https://docs.voxel51.com/user_guide/basics.html] and early computer vision concepts. This tutorial is recommended for beginners new to computer vision or FiftyOne. It will be helpful if you have run a model in FiftyOne or at worked with data that has both a "ground truth" and a "predictions" label

## Time to complete
5-10 minutes

## Required packages
FiftyOne and Pytorch are required. You can install both with
```
pip install fiftyone torch ultralytics pycocotools
```

## Content
    A small evaluation workflow through a subset of MSCOCO and CIFAR-10!