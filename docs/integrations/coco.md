# COCO Integration [¶](\#coco-integration "Permalink to this headline")

With support from the team behind the [COCO dataset](https://cocodataset.org),
we’ve made it easy to download, visualize, and evaluate on the COCO dataset
natively in FiftyOne!

Note

Check out [this tutorial](../tutorials/evaluate_detections.md) to see how
you can use FiftyOne to evaluate a model on COCO.

![coco-2017-validation](../_images/coco-2017-validation.webp)

## Loading the COCO dataset [¶](\#loading-the-coco-dataset "Permalink to this headline")

The FiftyOne Dataset Zoo provides support for loading both the
[COCO-2014](../data/dataset_zoo/datasets.md#dataset-zoo-coco-2014) and
[COCO-2017](../data/dataset_zoo/datasets.md#dataset-zoo-coco-2017) datasets.

Like all other zoo datasets, you can use
[`load_zoo_dataset()`](../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.load_zoo_dataset "fiftyone.zoo.datasets.load_zoo_dataset") to download
and load a COCO split into FiftyOne:

```python
import fiftyone as fo
import fiftyone.zoo as foz

# Download and load the validation split of COCO-2017
dataset = foz.load_zoo_dataset("coco-2017", split="validation")

session = fo.launch_app(dataset)

```

Note

FiftyOne supports loading annotations for the
[detection task](https://cocodataset.org/#detection-2020), including
bounding boxes and segmentations.

By default, only the bounding boxes are loaded, but you can customize which
label types are loaded via the optional `label_types` argument (see below
for details).

Note

We will soon support loading labels for the keypoints, captions, and
panoptic segmentation tasks as well. Stay tuned!

In addition, FiftyOne provides parameters that can be used to efficiently
download specific subsets of the COCO dataset, allowing you to quickly explore
different slices of the dataset without downloading the entire split.

When performing partial downloads, FiftyOne will use existing downloaded data
first if possible before resorting to downloading additional data from the web.

```python
import fiftyone as fo
import fiftyone.zoo as foz

#
# Load 50 random samples from the validation split
#
# Only the required images will be downloaded (if necessary).
# By default, only detections are loaded
#

dataset = foz.load_zoo_dataset(
    "coco-2017",
    split="validation",
    max_samples=50,
    shuffle=True,
)

session = fo.launch_app(dataset)

#
# Load segmentations for 25 samples from the validation split that
# contain cats and dogs
#
# Images that contain all `classes` will be prioritized first, followed
# by images that contain at least one of the required `classes`. If
# there are not enough images matching `classes` in the split to meet
# `max_samples`, only the available images will be loaded.
#
# Images will only be downloaded if necessary
#

dataset = foz.load_zoo_dataset(
    "coco-2017",
    split="validation",
    label_types=["segmentations"],
    classes=["cat", "dog"],
    max_samples=25,
)

session.dataset = dataset

```

The following parameters are available to configure partial downloads of both
COCO-2014 and COCO-2017 by passing them to
[`load_zoo_dataset()`](../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.load_zoo_dataset "fiftyone.zoo.datasets.load_zoo_dataset"):

- **split** ( _None_) and **splits** ( _None_): a string or list of strings,
respectively, specifying the splits to load. Supported values are
`("train", "test", "validation")`. If neither is provided, all available
splits are loaded

- **label\_types** ( _None_): a label type or list of label types to load.
Supported values are `("detections", "segmentations")`. By default, only
detections are loaded

- **classes** ( _None_): a string or list of strings specifying required
classes to load. If provided, only samples containing at least one instance
of a specified class will be loaded

- **image\_ids** ( _None_): a list of specific image IDs to load. The IDs can
be specified either as `<split>/<image-id>` strings or `<image-id>`
ints of strings. Alternatively, you can provide the path to a TXT
(newline-separated), JSON, or CSV file containing the list of image IDs to
load in either of the first two formats

- **include\_id** ( _False_): whether to include the COCO ID of each sample in
the loaded labels

- **include\_license** ( _False_): whether to include the COCO license of each
sample in the loaded labels, if available. The supported values are:

  - `"False"` (default): don’t load the license

  - `True`/ `"name"`: store the string license name

  - `"id"`: store the integer license ID

  - `"url"`: store the license URL
- **only\_matching** ( _False_): whether to only load labels that match the
`classes` or `attrs` requirements that you provide (True), or to load
all labels for samples that match the requirements (False)

- **num\_workers** ( _None_): the number of processes to use when downloading
individual images. By default, `multiprocessing.cpu_count()` is used

- **shuffle** ( _False_): whether to randomly shuffle the order in which
samples are chosen for partial downloads

- **seed** ( _None_): a random seed to use when shuffling

- **max\_samples** ( _None_): a maximum number of samples to load per split. If
`label_types` and/or `classes` are also specified, first priority will
be given to samples that contain all of the specified label types and/or
classes, followed by samples that contain at least one of the specified
labels types or classes. The actual number of samples loaded may be less
than this maximum value if the dataset does not contain sufficient samples
matching your requirements

Note

See
[`COCO2017Dataset`](../api/fiftyone.zoo.datasets.base.html#fiftyone.zoo.datasets.base.COCO2017Dataset "fiftyone.zoo.datasets.base.COCO2017Dataset") and
[`COCODetectionDatasetImporter`](../api/fiftyone.utils.coco.html#fiftyone.utils.coco.COCODetectionDatasetImporter "fiftyone.utils.coco.COCODetectionDatasetImporter")
for complete descriptions of the optional keyword arguments that you can
pass to [`load_zoo_dataset()`](../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.load_zoo_dataset "fiftyone.zoo.datasets.load_zoo_dataset").

## Loading COCO-formatted data [¶](\#loading-coco-formatted-data "Permalink to this headline")

In addition to loading the COCO datasets themselves, FiftyOne also makes it
easy to load your own datasets and model predictions stored in
[COCO format](https://cocodataset.org/#format-data).

The example code below demonstrates this workflow. First, we generate a JSON
file containing COCO-formatted labels to work with:

```python
import os

import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# The directory in which the dataset's images are stored
IMAGES_DIR = os.path.dirname(dataset.first().filepath)

# Export some labels in COCO format
dataset.take(5, seed=51).export(
    dataset_type=fo.types.COCODetectionDataset,
    label_field="ground_truth",
    labels_path="/tmp/coco.json",
)

```

Now we have a `/tmp/coco.json` file on disk containing COCO labels
corresponding to the images in `IMAGES_DIR`:

```python
python -m json.tool /tmp/coco.json

```

```python
{
    "info": {...},
    "licenses": [],
    "categories": [\
        {\
            "id": 1,\
            "name": "airplane",\
            "supercategory": null\
        },\
        ...\
    ],
    "images": [\
        {\
            "id": 1,\
            "file_name": "003486.jpg",\
            "height": 427,\
            "width": 640,\
            "license": null,\
            "coco_url": null\
        },\
        ...\
    ],
    "annotations": [\
        {\
            "id": 1,\
            "image_id": 1,\
            "category_id": 1,\
            "bbox": [\
                34.34,\
                147.46,\
                492.69,\
                192.36\
            ],\
            "area": 94773.8484,\
            "iscrowd": 0\
        },\
        ...\
    ]
}

```

We can now use
[`Dataset.from_dir()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.from_dir "fiftyone.core.dataset.Dataset.from_dir") to load the
[COCO-formatted labels](../fiftyone_concepts/dataset_creation/datasets.md#cocodetectiondataset-import) into a new FiftyOne
dataset:

```python
# Load COCO formatted dataset
coco_dataset = fo.Dataset.from_dir(
    dataset_type=fo.types.COCODetectionDataset,
    data_path=IMAGES_DIR,
    labels_path="/tmp/coco.json",
    include_id=True,
)

# COCO categories are also imported
print(coco_dataset.info["categories"])
# [{'id': 1, 'name': 'airplane', 'supercategory': None}, ...]

print(coco_dataset)

```

```python
Name:        2021.06.28.15.14.38
Media type:  image
Num samples: 5
Persistent:  False
Tags:        []
Sample fields:
    id:               fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.ImageMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    detections:       fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
    coco_id:          fiftyone.core.fields.IntField

```

In the above call to
[`Dataset.from_dir()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.from_dir "fiftyone.core.dataset.Dataset.from_dir"), we provide
the `data_path` and `labels_path` parameters to specify the
location of the source images and their COCO labels, respectively, and we set
`include_id=True` so that the COCO ID for each image from our JSON labels
will be added to each imported sample.

Note

See
[`COCODetectionDatasetImporter`](../api/fiftyone.utils.coco.html#fiftyone.utils.coco.COCODetectionDatasetImporter "fiftyone.utils.coco.COCODetectionDatasetImporter")
for complete descriptions of the optional keyword arguments that you can
pass to [`Dataset.from_dir()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.from_dir "fiftyone.core.dataset.Dataset.from_dir").

If your workflow generates model predictions in COCO format, you can use the
[`add_coco_labels()`](../api/fiftyone.utils.coco.html#fiftyone.utils.coco.add_coco_labels "fiftyone.utils.coco.add_coco_labels") utility method
to add them to your dataset as follows:

```python
import fiftyone.utils.coco as fouc

#
# Mock COCO predictions, where:
# - `image_id` corresponds to the `coco_id` field of `coco_dataset`
# - `category_id` corresponds to `coco_dataset.info["categories"]`
#
predictions = [\
    {"image_id": 1, "category_id": 2, "bbox": [258, 41, 348, 243], "score": 0.87},\
    {"image_id": 2, "category_id": 4, "bbox": [61, 22, 504, 609], "score": 0.95},\
]
categories = coco_dataset.info["categories"]

# Add COCO predictions to `predictions` field of dataset
fouc.add_coco_labels(coco_dataset, "predictions", predictions, categories)

# Verify that predictions were added to two images
print(coco_dataset.count("predictions"))  # 2

```

## COCO-style evaluation [¶](\#coco-style-evaluation "Permalink to this headline")

By default,
[`evaluate_detections()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.evaluate_detections "fiftyone.core.collections.SampleCollection.evaluate_detections")
will use [COCO-style evaluation](https://cocodataset.org/#detection-eval) to
analyze predictions.

You can also explicitly request that COCO-style evaluation be used by setting
the `method` parameter to `"coco"`.

See [this page](../fiftyone_concepts/evaluation.md#evaluating-detections) for more information about using
FiftyOne to analyze object detection models.

Note

FiftyOne’s implementation of COCO-style evaluation matches the reference
implementation available via
[pycocotools](https://github.com/cocodataset/cocoapi).

### Overview [¶](\#overview "Permalink to this headline")

When running COCO-style evaluation using
[`evaluate_detections()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.evaluate_detections "fiftyone.core.collections.SampleCollection.evaluate_detections"):

- Predicted and ground truth objects are matched using a specified IoU
threshold (default = 0.50). This threshold can be customized via the
`iou` parameter

- By default, only objects with the same `label` will be matched. Classwise
matching can be disabled via the `classwise` parameter

- Ground truth objects can have an `iscrowd` attribute that indicates
whether the annotation contains a crowd of objects. Multiple predictions
can be matched to crowd ground truth objects. The name of this attribute
can be customized by passing the optional `iscrowd` attribute of
[`COCOEvaluationConfig`](../api/fiftyone.utils.eval.coco.html#fiftyone.utils.eval.coco.COCOEvaluationConfig "fiftyone.utils.eval.coco.COCOEvaluationConfig") to
[`evaluate_detections()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.evaluate_detections "fiftyone.core.collections.SampleCollection.evaluate_detections")

When you specify an `eval_key` parameter, a number of helpful fields will be
populated on each sample and its predicted/ground truth objects:

- True positive (TP), false positive (FP), and false negative (FN) counts
for the each sample are saved in top-level fields of each sample:

```python
TP: sample.<eval_key>_tp
FP: sample.<eval_key>_fp
FN: sample.<eval_key>_fn

```

- The fields listed below are populated on each individual object instance;
these fields tabulate the TP/FP/FN status of the object, the ID of the
matching object (if any), and the matching IoU:

```python
TP/FP/FN: object.<eval_key>
        ID: object.<eval_key>_id
       IoU: object.<eval_key>_iou

```

Note

See [`COCOEvaluationConfig`](../api/fiftyone.utils.eval.coco.html#fiftyone.utils.eval.coco.COCOEvaluationConfig "fiftyone.utils.eval.coco.COCOEvaluationConfig") for complete descriptions of the optional
keyword arguments that you can pass to
[`evaluate_detections()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.evaluate_detections "fiftyone.core.collections.SampleCollection.evaluate_detections")
when running COCO-style evaluation.

### Example evaluation [¶](\#example-evaluation "Permalink to this headline")

The example below demonstrates COCO-style detection evaluation on the
[quickstart dataset](../data/dataset_zoo/datasets.md#dataset-zoo-quickstart) from the Dataset Zoo:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")
print(dataset)

# Evaluate the objects in the `predictions` field with respect to the
# objects in the `ground_truth` field
results = dataset.evaluate_detections(
    "predictions",
    gt_field="ground_truth",
    method="coco",
    eval_key="eval",
)

# Get the 10 most common classes in the dataset
counts = dataset.count_values("ground_truth.detections.label")
classes = sorted(counts, key=counts.get, reverse=True)[:10]

# Print a classification report for the top-10 classes
results.print_report(classes=classes)

# Print some statistics about the total TP/FP/FN counts
print("TP: %d" % dataset.sum("eval_tp"))
print("FP: %d" % dataset.sum("eval_fp"))
print("FN: %d" % dataset.sum("eval_fn"))

# Create a view that has samples with the most false positives first, and
# only includes false positive boxes in the `predictions` field
view = (
    dataset
    .sort_by("eval_fp", reverse=True)
    .filter_labels("predictions", F("eval") == "fp")
)

# Visualize results in the App
session = fo.launch_app(view=view)

```

```python
               precision    recall  f1-score   support

       person       0.45      0.74      0.56       783
         kite       0.55      0.72      0.62       156
          car       0.12      0.54      0.20        61
         bird       0.63      0.67      0.65       126
       carrot       0.06      0.49      0.11        47
         boat       0.05      0.24      0.08        37
    surfboard       0.10      0.43      0.17        30
     airplane       0.29      0.67      0.40        24
traffic light       0.22      0.54      0.31        24
        bench       0.10      0.30      0.15        23

    micro avg       0.32      0.68      0.43      1311
    macro avg       0.26      0.54      0.32      1311
 weighted avg       0.42      0.68      0.50      1311

```

![quickstart-evaluate-detections](../_images/quickstart_evaluate_detections.webp)

### mAP and PR curves [¶](\#map-and-pr-curves "Permalink to this headline")

You can compute mean average precision (mAP), mean average recall (mAR), and
precision-recall (PR) curves for your predictions by passing the
`compute_mAP=True` flag to
[`evaluate_detections()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.evaluate_detections "fiftyone.core.collections.SampleCollection.evaluate_detections"):

Note

All mAP and mAR calculations are performed according to the
[COCO evaluation protocol](https://cocodataset.org/#detection-eval).

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")
print(dataset)

# Performs an IoU sweep so that mAP, mAR, and PR curves can be computed
results = dataset.evaluate_detections(
    "predictions",
    gt_field="ground_truth",
    method="coco",
    compute_mAP=True,
)

print(results.mAP())
# 0.3957

print(results.mAR())
# 0.5210

plot = results.plot_pr_curves(classes=["person", "kite", "car"])
plot.show()

```

![coco-pr-curves](../_images/coco_pr_curves.webp)

### Confusion matrices [¶](\#confusion-matrices "Permalink to this headline")

You can also easily generate [confusion matrices](../fiftyone_concepts/evaluation.md#confusion-matrices) for
the results of COCO-style evaluations.

In order for the confusion matrix to capture anything other than false
positive/negative counts, you will likely want to set the
[`classwise`](../api/fiftyone.utils.eval.coco.html#fiftyone.utils.eval.coco.COCOEvaluationConfig "fiftyone.utils.eval.coco.COCOEvaluationConfig") parameter
to `False` during evaluation so that predicted objects can be matched with
ground truth objects of different classes.

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# Perform evaluation, allowing objects to be matched between classes
results = dataset.evaluate_detections(
    "predictions",
    gt_field="ground_truth",
    method="coco",
    classwise=False,
)

# Generate a confusion matrix for the specified classes
plot = results.plot_confusion_matrix(classes=["car", "truck", "motorcycle"])
plot.show()

```

![coco-confusion-matrix](../_images/coco_confusion_matrix.webp)

Note

Did you know? [Confusion matrices](../fiftyone_concepts/evaluation.md#confusion-matrices) can be
attached to your [`Session`](../api/fiftyone.core.session.html#fiftyone.core.session.Session "fiftyone.core.session.Session") object and dynamically explored using FiftyOne’s
[interactive plotting features](../fiftyone_concepts/plots.md#interactive-plots)!

## mAP protocol [¶](\#map-protocol "Permalink to this headline")

The [COCO evaluation protocol](https://cocodataset.org/#detection-eval) is a
popular evaluation protocol used by many works in the computer vision
community.

COCO-style mAP is derived from
[VOC-style evaluation](http://host.robots.ox.ac.uk/pascal/VOC/voc2010/devkit_doc_08-May-2010.pdf)
with the addition of a crowd attribute and an IoU sweep.

The steps to compute COCO-style mAP are detailed below.

**Preprocessing**

- Filter ground truth and predicted objects by class
(unless `classwise=False`)

- Sort predicted objects by confidence score so high confidence objects are
matched first. Only the top 100 predictions are factored into evaluation
(configurable with `max_preds`)

- Sort ground truth objects so `iscrowd` objects are matched last

- Compute IoU between every ground truth and predicted object within the same
class (and between classes if `classwise=False`) in each image

- IoU between predictions and crowd objects is calculated as the intersection
of both boxes divided by the area of the prediction only. A prediction fully
inside the crowd box has an IoU of 1

**Matching**

Once IoUs have been computed, predictions and ground truth objects are matched
to compute true positives, false positives, and false negatives:

- For each class, start with the highest confidence prediction, match it to
the ground truth object that it overlaps with the highest IoU. A prediction
only matches if the IoU is above the specified `iou` threshold

- If a prediction matched to a non-crowd object, it will not match to a crowd
even if the IoU is higher

- Multiple predictions can match to the same crowd ground truth object, each
counting as a true positive

- If a prediction maximally overlaps with a ground truth object that has
already been matched (by a higher confidence prediction), the prediction is
matched with the next highest IoU ground truth object

- (Only relevant if `classwise=False`) predictions can only match to crowds
if they are of the same class

**Computing mAP**

- Compute matches for 10 IoU thresholds from 0.5 to 0.95 in increments of
0.05

- The next 6 steps are computed separately for each
class and IoU threshold:

- Construct a boolean array of true positives and false positives, sorted
( [via mergesort](https://github.com/cocodataset/cocoapi/blob/8c9bcc3cf640524c4c20a9c40e89cb6a2f2fa0e9/PythonAPI/pycocotools/cocoeval.py#L366))
by confidence

- Compute the cumulative sum of the true positive and false positive array

- Compute precision by elementwise dividing the TP-FP-sum array by the total
number of predictions up to that point

- Compute recall by elementwise dividing TP-FP-sum array by the number of
ground truth objects for the class

- Ensure that precision is a non-increasing array

- Interpolate precision values so that they can be plotted with an array of
101 evenly spaced recall values

- For every class that contains at least one ground truth object, compute the
average precision (AP) by averaging the precision values over all 10 IoU
thresholds. Then compute mAP by averaging the per-class AP values over all
classes
