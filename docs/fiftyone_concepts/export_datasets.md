# Exporting FiftyOne Datasets [¶](\#exporting-fiftyone-datasets "Permalink to this headline")

FiftyOne provides native support for exporting datasets to disk in a
variety of [common formats](#supported-export-formats), and it can be
easily extended to export datasets in
[custom formats](#custom-dataset-exporter).

Note

Did you know? You can export media and/or labels from within the FiftyOne
App by installing the
[@voxel51/io](https://github.com/voxel51/fiftyone-plugins/tree/main/plugins/io)
plugin!

## Basic recipe [¶](\#basic-recipe "Permalink to this headline")

The interface for exporting a FiftyOne [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") is conveniently exposed via
the Python library and the CLI. You can easily export entire datasets as well
as arbitrary subsets of your datasets that you have identified by constructing
a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") into any format of your choice via the basic recipe below.

## Label type coercion [¶](\#label-type-coercion "Permalink to this headline")

For your convenience, the
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") method
will automatically coerce the data to match the requested export types in a
variety of common cases listed below.

### Single labels to lists [¶](\#single-labels-to-lists "Permalink to this headline")

Many export formats expect label list types
( [`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications"), [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"), or [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints")). If you provide
a label field to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") that
refers to a single label type ( [`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification"), [`Detection`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detection "fiftyone.core.labels.Detection"), [`Polyline`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polyline "fiftyone.core.labels.Polyline"), or
[`Keypoint`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoint "fiftyone.core.labels.Keypoint")), then the labels will be automatically upgraded to single-label
lists to match the export type’s expectations.

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")
patches = dataset.to_patches("ground_truth")

# The `ground_truth` field has type `Detection`, but COCO format expects
# `Detections`, so the labels are automatically coerced to single-label lists
patches.export(
    export_dir="/tmp/quickstart/detections",
    dataset_type=fo.types.COCODetectionDataset,
    label_field="ground_truth",
)

```

### Classifications as detections [¶](\#classifications-as-detections "Permalink to this headline")

When exporting in labeled image dataset formats that expect [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections")
labels, if you provide a label field to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") that has
type [`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification"), the classification labels will be automatically upgraded
to detections that span the entire images.

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart").limit(5).clone()

for idx, sample in enumerate(dataset):
    sample["attribute"] = fo.Classification(label=str(idx))
    sample.save()

# Exports the `attribute` classifications as detections that span entire images
dataset.export(
    export_dir="/tmp/quickstart/attributes",
    dataset_type=fo.types.COCODetectionDataset,
    label_field="attribute",
)

```

### Object patches [¶](\#object-patches "Permalink to this headline")

When exporting in either an unlabeled image or image classification format, if
a spatial label field ( [`Detection`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detection "fiftyone.core.labels.Detection"), [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polyline`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polyline "fiftyone.core.labels.Polyline"), or [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"))
is provided to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export"), the
[object patches](app.md#app-object-patches) of the provided samples will be
exported.

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# No label field is provided; only images are exported
dataset.export(
    export_dir="/tmp/quickstart/images",
    dataset_type=fo.types.ImageDirectory,
)

# A detections field is provided, so the object patches are exported as a
# directory of images
dataset.export(
    export_dir="/tmp/quickstart/patches",
    dataset_type=fo.types.ImageDirectory,
    label_field="ground_truth",
)

# A detections field is provided, so the object patches are exported as an
# image classification directory tree
dataset.export(
    export_dir="/tmp/quickstart/objects",
    dataset_type=fo.types.ImageClassificationDirectoryTree,
    label_field="ground_truth",
)

```

You can also directly call
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") on
[patches views](using_views.md#object-patches-views) to export the specified object
patches along with their appropriately typed labels.

```python
# Continuing from above...

patches = dataset.to_patches("ground_truth")

# Export the object patches as a directory of images
patches.export(
    export_dir="/tmp/quickstart/also-patches",
    dataset_type=fo.types.ImageDirectory,
)

# Export the object patches as an image classification directory tree
patches.export(
    export_dir="/tmp/quickstart/also-objects",
    dataset_type=fo.types.ImageClassificationDirectoryTree,
)

```

### Video clips [¶](\#video-clips "Permalink to this headline")

When exporting in either an unlabeled video or video classification format, if
a [`TemporalDetection`](../api/fiftyone.core.labels.html#fiftyone.core.labels.TemporalDetection "fiftyone.core.labels.TemporalDetection") or [`TemporalDetections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.TemporalDetections "fiftyone.core.labels.TemporalDetections") field is provided to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export"), the
specified [video clips](app.md#app-video-clips) will be exported.

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart-video", max_samples=2)

# Add some temporal detections to the dataset
sample1 = dataset.first()
sample1["events"] = fo.TemporalDetections(
    detections=[\
        fo.TemporalDetection(label="first", support=[31, 60]),\
        fo.TemporalDetection(label="second", support=[90, 120]),\
    ]
)
sample1.save()

sample2 = dataset.last()
sample2["events"] = fo.TemporalDetections(
    detections=[\
        fo.TemporalDetection(label="first", support=[16, 45]),\
        fo.TemporalDetection(label="second", support=[75, 104]),\
    ]
)
sample2.save()

# A temporal detection field is provided, so the clips are exported as a
# directory of videos
dataset.export(
    export_dir="/tmp/quickstart-video/clips",
    dataset_type=fo.types.VideoDirectory,
    label_field="events",
)

# A temporal detection field is provided, so the clips are exported as a
# video classification directory tree
dataset.export(
    export_dir="/tmp/quickstart-video/video-classifications",
    dataset_type=fo.types.VideoClassificationDirectoryTree,
    label_field="events",
)

```

You can also directly call
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") on
[clip views](using_views.md#clip-views) to export the specified video clips along with
their appropriately typed labels.

```python
# Continuing from above...

clips = dataset.to_clips("events")

# Export the clips as a directory of videos
clips.export(
    export_dir="/tmp/quickstart-video/also-clips",
    dataset_type=fo.types.VideoDirectory,
)

# Export the clips as a video classification directory tree
clips.export(
    export_dir="/tmp/quickstart-video/clip-classifications",
    dataset_type=fo.types.VideoClassificationDirectoryTree,
)

# Export the clips along with their associated frame labels
clips.export(
    export_dir="/tmp/quickstart-video/clip-frame-labels",
    dataset_type=fo.types.FiftyOneVideoLabelsDataset,
    frame_labels_field="detections",
)

```

## Class lists [¶](\#class-lists "Permalink to this headline")

Certain labeled image/video export formats such as
[COCO](#cocodetectiondataset-export) and
[YOLO](#yolov5dataset-export) store an explicit list of classes for the
label field being exported.

By convention, all exporters provided by FiftyOne should provide a `classes`
parameter that allows for manually specifying the classes list to use.

If no explicit class list is provided, the observed classes in the collection
being exported are used, which may be a subset of the classes in the parent
dataset when exporting a view.

Note

See [this section](using_datasets.md#storing-classes) for more information about
storing class lists on FiftyOne datasets.

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

# Load 10 samples containing cats and dogs (among other objects)
dataset = foz.load_zoo_dataset(
    "coco-2017",
    split="validation",
    classes=["cat", "dog"],
    shuffle=True,
    max_samples=10,
)

# Loading zoo datasets generally populates the `default_classes` attribute
print(len(dataset.default_classes))  # 91

# Create a view that only contains cats and dogs
view = dataset.filter_labels("ground_truth", F("label").is_in(["cat", "dog"]))

# By default, only the observed classes will be stored as COCO categories
view.export(
    labels_path="/tmp/coco1.json",
    dataset_type=fo.types.COCODetectionDataset,
)

# However, if desired, we can explicitly provide a classes list
view.export(
    labels_path="/tmp/coco2.json",
    dataset_type=fo.types.COCODetectionDataset,
    classes=dataset.default_classes,
)

```

## Supported formats [¶](\#supported-formats "Permalink to this headline")

Each supported dataset type is represented by a subclass of
[`fiftyone.types.Dataset`](../api/fiftyone.types.html#fiftyone.types.Dataset "fiftyone.types.Dataset"), which is used by the Python library and CLI to
refer to the corresponding dataset format when writing the dataset to disk.

| Dataset Type | Description |
| --- | --- |
| [ImageDirectory](#imagedirectory-export) | A directory of images. |
| [VideoDirectory](#videodirectory-export) | A directory of videos. |
| [MediaDirectory](#mediadirectory-export) | A directory of media files. |
| [FiftyOneImageClassificationDataset](#fiftyoneimageclassificationdataset-export) | A labeled dataset consisting of images and their associated classification labels<br>in a simple JSON format. |
| [ImageClassificationDirectoryTree](#imageclassificationdirectorytree-export) | A directory tree whose subfolders define an image classification dataset. |
| [VideoClassificationDirectoryTree](#videoclassificationdirectorytree-export) | A directory tree whose subfolders define a video classification dataset. |
| [TFImageClassificationDataset](#tfimageclassificationdataset-export) | A labeled dataset consisting of images and their associated classification labels<br>stored as TFRecords. |
| [FiftyOneImageDetectionDataset](#fiftyoneimagedetectiondataset-export) | A labeled dataset consisting of images and their associated object detections<br>stored in a simple JSON format. |
| [FiftyOneTemporalDetectionDataset](#fiftyonetemporaldetectiondataset-export) | A labeled dataset consisting of videos and their associated temporal detections in<br>a simple JSON format. |
| [COCODetectionDataset](#cocodetectiondataset-export) | A labeled dataset consisting of images and their associated object detections<br>saved in [COCO Object Detection Format](https://cocodataset.org/#format-data). |
| [VOCDetectionDataset](#vocdetectiondataset-export) | A labeled dataset consisting of images and their associated object detections<br>saved in [VOC format](http://host.robots.ox.ac.uk/pascal/VOC). |
| [KITTIDetectionDataset](#kittidetectiondataset-export) | A labeled dataset consisting of images and their associated object detections<br>saved in [KITTI format](http://www.cvlibs.net/datasets/kitti/eval_object.php). |
| [YOLOv4Dataset](#yolov4dataset-export) | A labeled dataset consisting of images and their associated object detections<br>saved in [YOLOv4 format](https://github.com/AlexeyAB/darknet). |
| [YOLOv5Dataset](#yolov5dataset-export) | A labeled dataset consisting of images and their associated object detections<br>saved in [YOLOv5 format](https://github.com/ultralytics/yolov5). |
| [TFObjectDetectionDataset](#tfobjectdetectiondataset-export) | A labeled dataset consisting of images and their associated object detections<br>stored as TFRecords in [TF Object Detection API format](https://github.com/tensorflow/models/blob/master/research/object_detection). |
| [ImageSegmentationDirectory](#imagesegmentationdirectory-export) | A labeled dataset consisting of images and their associated semantic segmentations<br>stored as images on disk. |
| [CVATImageDataset](#cvatimagedataset-export) | A labeled dataset consisting of images and their associated object detections<br>stored in [CVAT image format](https://github.com/opencv/cvat). |
| [CVATVideoDataset](#cvatvideodataset-export) | A labeled dataset consisting of videos and their associated object detections<br>stored in [CVAT video format](https://github.com/opencv/cvat). |
| [FiftyOneImageLabelsDataset](#fiftyoneimagelabelsdataset-export) | A labeled dataset consisting of images and their associated multitask predictions<br>stored in [ETA ImageLabels format](https://github.com/voxel51/eta/blob/develop/docs/image_labels_guide.md). |
| [FiftyOneVideoLabelsDataset](#fiftyonevideolabelsdataset-export) | A labeled dataset consisting of videos and their associated multitask predictions<br>stored in [ETA VideoLabels format](https://github.com/voxel51/eta/blob/develop/docs/video_labels_guide.md). |
| [BDDDataset](#bdddataset-export) | A labeled dataset consisting of images and their associated multitask predictions<br>saved in [Berkeley DeepDrive (BDD) format](https://bdd-data.berkeley.edu). |
| [CSVDataset](#csvdataset-export) | A flexible CSV format that represents slice(s) of a dataset’s values as columns of<br>a CSV file. |
| [GeoJSONDataset](#geojsondataset-export) | An image or video dataset whose location data and labels are stored in<br>[GeoJSON format](https://en.wikipedia.org/wiki/GeoJSON). |
| [FiftyOneDataset](#fiftyonedataset-export) | A dataset consisting of an entire serialized [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") and its associated source<br>media. |
| [Custom formats](#custom-dataset-exporter) | Export datasets in custom formats by defining your own [`Dataset`](../api/fiftyone.types.html#fiftyone.types.Dataset "fiftyone.types.Dataset") or<br>[`DatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.DatasetExporter "fiftyone.utils.data.exporters.DatasetExporter") class. |

## ImageDirectory [¶](\#imagedirectory "Permalink to this headline")

The [`fiftyone.types.ImageDirectory`](../api/fiftyone.types.html#fiftyone.types.ImageDirectory "fiftyone.types.ImageDirectory") type represents a directory of
images.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    <filename1>.<ext>
    <filename2>.<ext>
    ...

```

Note

See [`ImageDirectoryExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.ImageDirectoryExporter "fiftyone.utils.data.exporters.ImageDirectoryExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export the images in a FiftyOne dataset as a directory of images on
disk as follows:

## VideoDirectory [¶](\#videodirectory "Permalink to this headline")

The [`fiftyone.types.VideoDirectory`](../api/fiftyone.types.html#fiftyone.types.VideoDirectory "fiftyone.types.VideoDirectory") type represents a directory of
videos.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    <filename1>.<ext>
    <filename2>.<ext>
    ...

```

Note

See [`VideoDirectoryExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.VideoDirectoryExporter "fiftyone.utils.data.exporters.VideoDirectoryExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export the videos in a FiftyOne dataset as a directory of videos on
disk as follows:

## MediaDirectory [¶](\#mediadirectory "Permalink to this headline")

The [`fiftyone.types.MediaDirectory`](../api/fiftyone.types.html#fiftyone.types.MediaDirectory "fiftyone.types.MediaDirectory") type represents a directory of
media files.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    <filename1>.<ext>
    <filename2>.<ext>
    ...

```

Note

See [`MediaDirectoryExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.MediaDirectoryExporter "fiftyone.utils.data.exporters.MediaDirectoryExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export the media in a FiftyOne dataset as a directory of media files on
disk as follows:

## FiftyOneImageClassificationDataset [¶](\#fiftyoneimageclassificationdataset "Permalink to this headline")

Supported label types

[`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification"), [`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications")

The [`fiftyone.types.FiftyOneImageClassificationDataset`](../api/fiftyone.types.html#fiftyone.types.FiftyOneImageClassificationDataset "fiftyone.types.FiftyOneImageClassificationDataset") type represents
a labeled dataset consisting of images and their associated classification
label(s) stored in a simple JSON format.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels.json

```

In the simplest case, `labels.json` will be a JSON file in the following
format:

```python
{
    "classes": [\
        "<labelA>",\
        "<labelB>",\
        ...\
    ],
    "labels": {
        "<uuid1>": <target>,
        "<uuid2>": <target>,
        ...
    }
}

```

If the `classes` field is included in the JSON, the `target` values are class
IDs that are mapped to class label strings via `classes[target]`. If no
`classes` are included, then the `target` values directly store the label
strings.

The target value in `labels` for unlabeled images is `None`.

If you wish to export classifications with associated confidences and/or
additional attributes, you can use the `include_confidence` and
`include_attributes` parameters to include this information in the export.
In this case, `labels.json` will have the following format:

```python
{
    "classes": [\
        "<labelA>",\
        "<labelB>",\
        ...\
    ],
    "labels": {
        "<uuid1>": {
            "label": <target>,
            "confidence": <optional-confidence>,
            "attributes": {
                <optional-name>: <optional-value>,
                ...
            }
        },
        "<uuid2>": {
            "label": <target>,
            "confidence": <optional-confidence>,
            "attributes": {
                <optional-name>: <optional-value>,
                ...
            }
        },
        ...
    }
}

```

You can also export multilabel classification fields, in which case
`labels.json` will have the following format:

```python
{
    "classes": [\
        "<labelA>",\
        "<labelB>",\
        ...\
    ],
    "labels": {
        "<uuid1>": [<target1>, <target2>, ...],
        "<uuid2>": [<target1>, <target2>, ...],
        ...
    }
}

```

where the target values in `labels` may be class strings, class IDs, or dicts
in the format described above defining class labels, confidences, and optional
attributes, depending on how you configured the export.

Note

See [`FiftyOneImageClassificationDatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.FiftyOneImageClassificationDatasetExporter "fiftyone.utils.data.exporters.FiftyOneImageClassificationDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as an image classification dataset stored on
disk in the above format as follows:

Note

You can pass the optional `classes` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
explicitly define the class list to use in the exported labels. Otherwise,
the strategy outlined in [this section](#export-class-lists) will be
used to populate the class list.

You can also perform labels-only exports in this format by providing the
`labels_path` parameter instead of `export_dir` to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to specify
a location to write (only) the labels.

Note

You can optionally include the `export_media=False` option to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
make it explicit that you only wish to export labels, although this will be
inferred if you do not provide an `export_dir` or `data_path`.

By default, the filenames of your images will be used as keys in the exported
labels. However, you can also provide the optional `rel_dir` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to specify
a prefix to strip from each image path to generate a key for the image. This
argument allows for populating nested subdirectories that match the shape of
the input paths.

## ImageClassificationDirectoryTree [¶](\#imageclassificationdirectorytree "Permalink to this headline")

Supported label types

[`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification")

The [`fiftyone.types.ImageClassificationDirectoryTree`](../api/fiftyone.types.html#fiftyone.types.ImageClassificationDirectoryTree "fiftyone.types.ImageClassificationDirectoryTree") type represents a
directory tree whose subfolders define an image classification dataset.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    <classA>/
        <image1>.<ext>
        <image2>.<ext>
        ...
    <classB>/
        <image1>.<ext>
        <image2>.<ext>
        ...
    ...

```

Unlabeled images are stored in a subdirectory named `_unlabeled`.

Note

See [`ImageClassificationDirectoryTreeExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.ImageClassificationDirectoryTreeExporter "fiftyone.utils.data.exporters.ImageClassificationDirectoryTreeExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as an image classification directory tree
stored on disk in the above format as follows:

## VideoClassificationDirectoryTree [¶](\#videoclassificationdirectorytree "Permalink to this headline")

Supported label types

[`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification")

The [`fiftyone.types.VideoClassificationDirectoryTree`](../api/fiftyone.types.html#fiftyone.types.VideoClassificationDirectoryTree "fiftyone.types.VideoClassificationDirectoryTree") type represents a
directory tree whose subfolders define a video classification dataset.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    <classA>/
        <video1>.<ext>
        <video2>.<ext>
        ...
    <classB>/
        <video1>.<ext>
        <video2>.<ext>
        ...
    ...

```

Unlabeled videos are stored in a subdirectory named `_unlabeled`.

Note

See [`VideoClassificationDirectoryTreeExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.VideoClassificationDirectoryTreeExporter "fiftyone.utils.data.exporters.VideoClassificationDirectoryTreeExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a video classification directory tree
stored on disk in the above format as follows:

## TFImageClassificationDataset [¶](\#tfimageclassificationdataset "Permalink to this headline")

Supported label types

[`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification")

The [`fiftyone.types.TFImageClassificationDataset`](../api/fiftyone.types.html#fiftyone.types.TFImageClassificationDataset "fiftyone.types.TFImageClassificationDataset") type represents a
labeled dataset consisting of images and their associated classification labels
stored as
[TFRecords](https://www.tensorflow.org/tutorials/load_data/tfrecord).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    tf.records-?????-of-?????

```

where the features of the (possibly sharded) TFRecords are stored in the
following format:

```python
{
    # Image dimensions
    "height": tf.io.FixedLenFeature([], tf.int64),
    "width": tf.io.FixedLenFeature([], tf.int64),
    "depth": tf.io.FixedLenFeature([], tf.int64),
    # Image filename
    "filename": tf.io.FixedLenFeature([], tf.int64),
    # The image extension
    "format": tf.io.FixedLenFeature([], tf.string),
    # Encoded image bytes
    "image_bytes": tf.io.FixedLenFeature([], tf.string),
    # Class label string
    "label": tf.io.FixedLenFeature([], tf.string, default_value=""),
}

```

For unlabeled samples, the TFRecords do not contain `label` features.

Note

See `TFImageClassificationDatasetExporter`
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a directory of TFRecords in the above
format as follows:

Note

You can provide the `tf_records_path` argument instead of `export_dir` in
the examples above to directly specify the path to the TFRecord(s) to
write. See
`TFImageClassificationDatasetExporter`
for details.

## FiftyOneImageDetectionDataset [¶](\#fiftyoneimagedetectiondataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections")

The [`fiftyone.types.FiftyOneImageDetectionDataset`](../api/fiftyone.types.html#fiftyone.types.FiftyOneImageDetectionDataset "fiftyone.types.FiftyOneImageDetectionDataset") type represents a
labeled dataset consisting of images and their associated object detections
stored in a simple JSON format.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels.json

```

where `labels.json` is a JSON file in the following format:

```python
{
    "classes": [\
        <labelA>,\
        <labelB>,\
        ...\
    ],
    "labels": {
        <uuid1>: [\
            {\
                "label": <target>,\
                "bounding_box": [\
                    <top-left-x>, <top-left-y>, <width>, <height>\
                ],\
                "confidence": <optional-confidence>,\
                "attributes": {\
                    <optional-name>: <optional-value>,\
                    ...\
                }\
            },\
            ...\
        ],
        <uuid2>: [\
            ...\
        ],
        ...
    }
}

```

and where the bounding box coordinates are expressed as relative values in
`[0, 1] x [0, 1]`.

If the `classes` field is included in the JSON, the `target` values are class
IDs that are mapped to class label strings via `classes[target]`. If no
`classes` are included, then the `target` values directly store the label
strings.

The target value in `labels` for unlabeled images is `None`.

By default, confidences and any additional dynamic attributes of your
detections will be automatically included in the export. However, you can
provide the optional `include_confidence` and `include_attributes` parameters
to customize this behavior.

Note

See [`FiftyOneImageDetectionDatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.FiftyOneImageDetectionDatasetExporter "fiftyone.utils.data.exporters.FiftyOneImageDetectionDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as an image detection dataset in the above
format as follows:

Note

You can pass the optional `classes` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
explicitly define the class list to use in the exported labels. Otherwise,
the strategy outlined in [this section](#export-class-lists) will be
used to populate the class list.

You can also perform labels-only exports in this format by providing the
`labels_path` parameter instead of `export_dir` to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to specify
a location to write (only) the labels.

Note

You can optionally include the `export_media=False` option to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
make it explicit that you only wish to export labels, although this will be
inferred if you do not provide an `export_dir` or `data_path`.

By default, the filenames of your images will be used as keys in the exported
labels. However, you can also provide the optional `rel_dir` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to specify
a prefix to strip from each image path to generate a key for the image. This
argument allows for populating nested subdirectories that match the shape of
the input paths.

## FiftyOneTemporalDetectionDataset [¶](\#fiftyonetemporaldetectiondataset "Permalink to this headline")

Supported label types

[`TemporalDetections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.TemporalDetections "fiftyone.core.labels.TemporalDetections")

The [`fiftyone.types.FiftyOneTemporalDetectionDataset`](../api/fiftyone.types.html#fiftyone.types.FiftyOneTemporalDetectionDataset "fiftyone.types.FiftyOneTemporalDetectionDataset") type represents a
labeled dataset consisting of videos and their associated temporal detections
stored in a simple JSON format.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels.json

```

where `labels.json` is a JSON file in the following format:

```python
{
    "classes": [\
        "<labelA>",\
        "<labelB>",\
        ...\
    ],
    "labels": {
        "<uuid1>": [\
            {\
                "label": <target>,\
                "support": [<first-frame>, <last-frame>],\
                "confidence": <optional-confidence>,\
                "attributes": {\
                    <optional-name>: <optional-value>,\
                    ...\
                }\
            },\
            {\
                "label": <target>,\
                "support": [<first-frame>, <last-frame>],\
                "confidence": <optional-confidence>,\
                "attributes": {\
                    <optional-name>: <optional-value>,\
                    ...\
                }\
            },\
            ...\
        ],
        "<uuid2>": [\
            {\
                "label": <target>,\
                "timestamps": [<start-timestamp>, <stop-timestamp>],\
                "confidence": <optional-confidence>,\
                "attributes": {\
                    <optional-name>: <optional-value>,\
                    ...\
                }\
            },\
            {\
                "label": <target>,\
                "timestamps": [<start-timestamp>, <stop-timestamp>],\
                "confidence": <optional-confidence>,\
                "attributes": {\
                    <optional-name>: <optional-value>,\
                    ...\
                }\
            },\
        ],
        ...
    }
}

```

By default, the `support` keys will be populated with the `[first, last]` frame
numbers of the detections, but you can pass the `use_timestamps=True` key
during export to instead populate the `timestamps` keys with the
`[start, stop]` timestamps of the detections, in seconds.

If the `classes` field is included in the JSON, the `target` values are class
IDs that are mapped to class label strings via `classes[target]`. If no
`classes` are included, then the `target` values directly store the label
strings.

The target value in `labels` for unlabeled videos is `None`.

By default, confidences and any additional dynamic attributes of your
detections will be automatically included in the export. However, you can
provide the optional `include_confidence` and `include_attributes` parameters
to customize this behavior.

Note

See [`FiftyOneTemporalDetectionDatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.FiftyOneTemporalDetectionDatasetExporter "fiftyone.utils.data.exporters.FiftyOneTemporalDetectionDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a temporal detection dataset stored on
disk in the above format as follows:

Note

You can pass the optional `classes` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
explicitly define the class list to use in the exported labels. Otherwise,
the strategy outlined in [this section](#export-class-lists) will be
used to populate the class list.

You can also perform labels-only exports in this format by providing the
`labels_path` parameter instead of `export_dir` to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to specify
a location to write (only) the labels.

Note

You can optionally include the `export_media=False` option to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
make it explicit that you only wish to export labels, although this will be
inferred if you do not provide an `export_dir` or `data_path`.

By default, the filenames of your images will be used as keys in the exported
labels. However, you can also provide the optional `rel_dir` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to specify
a prefix to strip from each image path to generate a key for the image. This
argument allows for populating nested subdirectories that match the shape of
the input paths.

## COCODetectionDataset [¶](\#cocodetectiondataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"), [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints")

The [`fiftyone.types.COCODetectionDataset`](../api/fiftyone.types.html#fiftyone.types.COCODetectionDataset "fiftyone.types.COCODetectionDataset") type represents a labeled
dataset consisting of images and their associated object detections saved in
[COCO Object Detection Format](https://cocodataset.org/#format-data).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <filename0>.<ext>
        <filename1>.<ext>
        ...
    labels.json

```

where `labels.json` is a JSON file in the following format:

```python
{
    "info": {
        "year": "",
        "version": "",
        "description": "Exported from FiftyOne",
        "contributor": "",
        "url": "https://voxel51.com/fiftyone",
        "date_created": "2020-06-19T09:48:27"
    },
    "licenses": [],
    "categories": [\
        {\
            "id": 1,\
            "name": "cat",\
            "supercategory": "animal"\
        },\
        ...\
    ],
    "images": [\
        {\
            "id": 1,\
            "license": null,\
            "file_name": "<filename0>.<ext>",\
            "height": 480,\
            "width": 640,\
            "date_captured": null\
        },\
        ...\
    ],
    "annotations": [\
        {\
            "id": 1,\
            "image_id": 1,\
            "category_id": 1,\
            "bbox": [260, 177, 231, 199],\
            "segmentation": [...],\
            "score": 0.95,\
            "area": 45969,\
            "iscrowd": 0\
        },\
        ...\
    ]
}

```

See [this page](https://cocodataset.org/#format-data) for a full
specification of the `segmentation` field, which will only be included if you
export [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") with instance masks populated or [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines").

For unlabeled datasets, `labels.json` does not contain an `annotations` field.

The `file_name` attribute of the labels file encodes the location of the
corresponding images, which can be any of the following:

- The filename of an image in the `data/` folder

- A relative path like `path/to/filename.ext` specifying the relative path to
the image in a nested subfolder of `data/`

- An absolute path to an image, which may or may not be in the `data/` folder

Note

See [`COCODetectionDatasetExporter`](../api/fiftyone.utils.coco.html#fiftyone.utils.coco.COCODetectionDatasetExporter "fiftyone.utils.coco.COCODetectionDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a COCO detection dataset in the above
format as follows:

Note

You can pass the optional `classes` or `categories` parameters to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
explicitly define the class list/category IDs to use in the exported
labels. Otherwise, the strategy outlined in
[this section](#export-class-lists) will be used to populate the class
list.

You can also perform labels-only exports of COCO-formatted labels by providing
the `labels_path` parameter instead of `export_dir`:

## VOCDetectionDataset [¶](\#vocdetectiondataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections")

The [`fiftyone.types.VOCDetectionDataset`](../api/fiftyone.types.html#fiftyone.types.VOCDetectionDataset "fiftyone.types.VOCDetectionDataset") type represents a labeled
dataset consisting of images and their associated object detections saved in
[VOC format](http://host.robots.ox.ac.uk/pascal/VOC).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels/
        <uuid1>.xml
        <uuid2>.xml
        ...

```

where the labels XML files are in the following format:

```python
<annotation>
    <folder></folder>
    <filename>image.ext</filename>
    <path>/path/to/dataset-dir/data/image.ext</path>
    <source>
        <database></database>
    </source>
    <size>
        <width>640</width>
        <height>480</height>
        <depth>3</depth>
    </size>
    <segmented></segmented>
    <object>
        <name>cat</name>
        <pose></pose>
        <truncated>0</truncated>
        <difficult>0</difficult>
        <occluded>0</occluded>
        <bndbox>
            <xmin>256</xmin>
            <ymin>200</ymin>
            <xmax>450</xmax>
            <ymax>400</ymax>
        </bndbox>
    </object>
    <object>
        <name>dog</name>
        <pose></pose>
        <truncated>1</truncated>
        <difficult>1</difficult>
        <occluded>1</occluded>
        <bndbox>
            <xmin>128</xmin>
            <ymin>100</ymin>
            <xmax>350</xmax>
            <ymax>300</ymax>
        </bndbox>
    </object>
    ...
</annotation>

```

Samples with no values for certain attributes (like `pose` in the above
example) are left empty.

Unlabeled images have no corresponding file in `labels/`.

Note

See [`VOCDetectionDatasetExporter`](../api/fiftyone.utils.voc.html#fiftyone.utils.voc.VOCDetectionDatasetExporter "fiftyone.utils.voc.VOCDetectionDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a VOC detection dataset in the above
format as follows:

You can also perform labels-only exports of VOC-formatted labels by providing
the `labels_path` parameter instead of `export_dir`:

## KITTIDetectionDataset [¶](\#kittidetectiondataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections")

The [`fiftyone.types.KITTIDetectionDataset`](../api/fiftyone.types.html#fiftyone.types.KITTIDetectionDataset "fiftyone.types.KITTIDetectionDataset") type represents a labeled
dataset consisting of images and their associated object detections saved in
[KITTI format](http://www.cvlibs.net/datasets/kitti/eval_object.php).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels/
        <uuid1>.txt
        <uuid2>.txt
        ...

```

where the labels TXT files are space-delimited files where each row corresponds
to an object and the 15 (and optional 16th score) columns have the following
meanings:

| \# of<br>columns | Name | Description | Default |
| --- | --- | --- | --- |
| 1 | type | The object label |  |
| 1 | truncated | A float in `[0, 1]`, where 0 is non-truncated and<br>1 is fully truncated. Here, truncation refers to the object<br>leaving image boundaries | 0 |
| 1 | occluded | An int in `(0, 1, 2, 3)` indicating occlusion state,<br>where:- 0 = fully visible- 1 = partly occluded- 2 =<br>largely occluded- 3 = unknown | 0 |
| 1 | alpha | Observation angle of the object, in `[-pi, pi]` | 0 |
| 4 | bbox | 2D bounding box of object in the image in pixels, in the<br>format `[xtl, ytl, xbr, ybr]` |  |
| 1 | dimensions | 3D object dimensions, in meters, in the format<br>`[height, width, length]` | 0 |
| 1 | location | 3D object location `(x, y, z)` in camera coordinates<br>(in meters) | 0 |
| 1 | rotation\_y | Rotation around the y-axis in camera coordinates, in<br>`[-pi, pi]` | 0 |
| 1 | score | `(optional)` A float confidence for the detection |  |

The `default` column above indicates the default value that will be used when
writing datasets in this type whose samples do not contain the necessary
field(s).

Unlabeled images have no corresponding file in `labels/`.

Note

See [`KITTIDetectionDatasetExporter`](../api/fiftyone.utils.kitti.html#fiftyone.utils.kitti.KITTIDetectionDatasetExporter "fiftyone.utils.kitti.KITTIDetectionDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a KITTI detection dataset in the above
format as follows:

You can also perform labels-only exports of KITTI-formatted labels by providing
the `labels_path` parameter instead of `export_dir`:

## YOLOv4Dataset [¶](\#yolov4dataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines")

The [`fiftyone.types.YOLOv4Dataset`](../api/fiftyone.types.html#fiftyone.types.YOLOv4Dataset "fiftyone.types.YOLOv4Dataset") type represents a labeled dataset
consisting of images and their associated object detections saved in
[YOLOv4 format](https://github.com/AlexeyAB/darknet).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    obj.names
    images.txt
    data/
        <uuid1>.<ext>
        <uuid1>.txt
        <uuid2>.<ext>
        <uuid2>.txt
        ...

```

where `obj.names` contains the object class labels:

```python
<label-0>
<label-1>
...

```

and `images.txt` contains the list of images in `data/`:

```python
data/<uuid1>.<ext>
data/<uuid2>.<ext>
...

```

and the TXT files in `data/` are space-delimited files where each row
corresponds to an object in the image of the same name, in one of the following
formats:

```python
# Detections
<target> <x-center> <y-center> <width> <height>
<target> <x-center> <y-center> <width> <height> <confidence>

# Polygons
<target> <x1> <y1> <x2> <y2> <x3> <y3> ...

```

where `<target>` is the zero-based integer index of the object class label from
`obj.names`, all coordinates are expressed as relative values in
`[0, 1] x [0, 1]`, and `<confidence>` is an optional confidence in `[0, 1]`,
which will be included only if you pass the optional `include_confidence=True`
flag to the export.

Unlabeled images have no corresponding TXT file in `data/`.

Note

See [`YOLOv4DatasetExporter`](../api/fiftyone.utils.yolo.html#fiftyone.utils.yolo.YOLOv4DatasetExporter "fiftyone.utils.yolo.YOLOv4DatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a YOLOv4 dataset in the above format as
follows:

Note

You can pass the optional `classes` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
explicitly define the class list to use in the exported labels. Otherwise,
the strategy outlined in [this section](#export-class-lists) will be
used to populate the class list.

You can also perform labels-only exports of YOLO-formatted labels by providing
the `labels_path` parameter instead of `export_dir`:

## YOLOv5Dataset [¶](\#yolov5dataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines")

The [`fiftyone.types.YOLOv5Dataset`](../api/fiftyone.types.html#fiftyone.types.YOLOv5Dataset "fiftyone.types.YOLOv5Dataset") type represents a labeled dataset
consisting of images and their associated object detections saved in
[YOLOv5 format](https://github.com/ultralytics/yolov5).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    dataset.yaml
    images/
        train/
            <uuid1>.<ext>
            <uuid2>.<ext>
            ...
        val/
            <uuid3>.<ext>
            <uuid4>.<ext>
            ...
    labels/
        train/
            <uuid1>.txt
            <uuid2>.txt
            ...
        val/
            <uuid3>.txt
            <uuid4>.txt
            ...

```

where `dataset.yaml` contains the following information:

```python
path: <dataset_dir>  # optional
train: ./images/train/
val: ./images/val/

names:
  0: list
  1: of
  2: classes
  ...

```

See [this page](https://docs.ultralytics.com/datasets/detect) for a full
description of the possible format of `dataset.yaml`. In particular, the
dataset may contain one or more splits with arbitrary names, as the specific
split being imported or exported is specified by the `split` argument to
[`fiftyone.utils.yolo.YOLOv5DatasetExporter`](../api/fiftyone.utils.yolo.html#fiftyone.utils.yolo.YOLOv5DatasetExporter "fiftyone.utils.yolo.YOLOv5DatasetExporter"). Also, `dataset.yaml` can be
located outside of `<dataset_dir>` as long as the optional `path` is provided.

The TXT files in `labels/` are space-delimited files where each row corresponds
to an object in the image of the same name, in one of the following formats:

```python
# Detections
<target> <x-center> <y-center> <width> <height>
<target> <x-center> <y-center> <width> <height> <confidence>

# Polygons
<target> <x1> <y1> <x2> <y2> <x3> <y3> ...

```

where `<target>` is the zero-based integer index of the object class label from
`names`, all coordinates are expressed as relative values in `[0, 1] x [0, 1]`,
and `<confidence>` is an optional confidence in `[0, 1]`, which will be
included only if you pass the optional `include_confidence=True` flag to the
export.

Unlabeled images have no corresponding TXT file in `labels/`. The label file
path for each image is obtained by replacing `images/` with `labels/` in the
respective image path.

Note

See [`YOLOv5DatasetExporter`](../api/fiftyone.utils.yolo.html#fiftyone.utils.yolo.YOLOv5DatasetExporter "fiftyone.utils.yolo.YOLOv5DatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a YOLOv5 dataset in the above format as
follows:

```python
import fiftyone as fo

export_dir = "/path/for/yolov5-dataset"
label_field = "ground_truth"  # for example

# The splits to export
splits = ["train", "val"]

# All splits must use the same classes list
classes = ["list", "of", "classes"]

# The dataset or view to export
# We assume the dataset uses sample tags to encode the splits to export
dataset_or_view = fo.load_dataset(...)

# Export the splits
for split in splits:
    split_view = dataset_or_view.match_tags(split)
    split_view.export(
        export_dir=export_dir,
        dataset_type=fo.types.YOLOv5Dataset,
        label_field=label_field,
        split=split,
        classes=classes,
    )

```

Note

You can pass the optional `classes` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
explicitly define the class list to use in the exported labels. Otherwise,
the strategy outlined in [this section](#export-class-lists) will be
used to populate the class list.

You can also perform labels-only exports of YOLO-formatted labels by providing
the `labels_path` parameter instead of `export_dir`:

```python
import fiftyone as fo

labels_path = "/path/for/yolo-labels"
label_field = "ground_truth"  # for example

# The dataset or view to export
dataset_or_view = fo.load_dataset(...)

# Export labels
dataset_or_view.export(
    dataset_type=fo.types.YOLOv5Dataset,
    labels_path=labels_path,
    label_field=label_field,
)

```

## TFObjectDetectionDataset [¶](\#tfobjectdetectiondataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections")

The [`fiftyone.types.TFObjectDetectionDataset`](../api/fiftyone.types.html#fiftyone.types.TFObjectDetectionDataset "fiftyone.types.TFObjectDetectionDataset") type represents a labeled
dataset consisting of images and their associated object detections stored as
[TFRecords](https://www.tensorflow.org/tutorials/load_data/tfrecord) in
[TF Object Detection API format](https://github.com/tensorflow/models/blob/master/research/object_detection).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    tf.records-?????-of-?????

```

where the features of the (possibly sharded) TFRecords are stored in the
following format:

```python
{
    # Image dimensions
    "image/height": tf.io.FixedLenFeature([], tf.int64),
    "image/width": tf.io.FixedLenFeature([], tf.int64),

    # Image filename is used for both of these when writing
    "image/filename": tf.io.FixedLenFeature([], tf.string),
    "image/source_id": tf.io.FixedLenFeature([], tf.string),

    # Encoded image bytes
    "image/encoded": tf.io.FixedLenFeature([], tf.string),

    # Image format, either `jpeg` or `png`
    "image/format": tf.io.FixedLenFeature([], tf.string),

    # Normalized bounding box coordinates in `[0, 1]`
    "image/object/bbox/xmin": tf.io.FixedLenSequenceFeature(
        [], tf.float32, allow_missing=True
    ),
    "image/object/bbox/xmax": tf.io.FixedLenSequenceFeature(
        [], tf.float32, allow_missing=True
    ),
    "image/object/bbox/ymin": tf.io.FixedLenSequenceFeature(
        [], tf.float32, allow_missing=True
    ),
    "image/object/bbox/ymax": tf.io.FixedLenSequenceFeature(
        [], tf.float32, allow_missing=True
    ),

    # Class label string
    "image/object/class/text": tf.io.FixedLenSequenceFeature(
        [], tf.string, allow_missing=True
    ),

    # Integer class ID
    "image/object/class/label": tf.io.FixedLenSequenceFeature(
        [], tf.int64, allow_missing=True
    ),
}

```

The TFRecords for unlabeled samples do not contain `image/object/*` features.

Note

See `TFObjectDetectionDatasetExporter`
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a directory of TFRecords in the above
format as follows:

Note

You can provide the `tf_records_path` argument instead of `export_dir` in
the examples above to directly specify the path to the TFRecord(s) to
write. See
`TFObjectDetectionDatasetExporter`
for details.

Note

You can pass the optional `classes` parameter to
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") to
explicitly define the class list to use in the exported labels. Otherwise,
the strategy outlined in [this section](#export-class-lists) will be
used to populate the class list.

## ImageSegmentationDirectory [¶](\#imagesegmentationdirectory "Permalink to this headline")

Supported label types

[`Segmentation`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Segmentation "fiftyone.core.labels.Segmentation"), [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines")

The [`fiftyone.types.ImageSegmentationDirectory`](../api/fiftyone.types.html#fiftyone.types.ImageSegmentationDirectory "fiftyone.types.ImageSegmentationDirectory") type represents a
labeled dataset consisting of images and their associated semantic
segmentations stored as images on disk.

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <filename1>.<ext>
        <filename2>.<ext>
        ...
    labels/
        <filename1>.<ext>
        <filename2>.<ext>
        ...

```

where `labels/` contains the semantic segmentations stored as images.

By default, the masks will be stored as PNG images, but you can customize this
by passing the optional `mask_format` parameter. The masks will be stored as 8
bit images if they contain at most 256 classes, otherwise 16 bits will be used.

Unlabeled images have no corresponding file in `labels/`.

Note

See [`ImageSegmentationDirectoryExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.ImageSegmentationDirectoryExporter "fiftyone.utils.data.exporters.ImageSegmentationDirectoryExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as an image segmentation dataset in the above
format as follows:

You can also export only the segmentation masks by providing the `labels_path`
parameter instead of `export_dir`:

## CVATImageDataset [¶](\#cvatimagedataset "Permalink to this headline")

Supported label types

[`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications"), [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"), [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints")

The [`fiftyone.types.CVATImageDataset`](../api/fiftyone.types.html#fiftyone.types.CVATImageDataset "fiftyone.types.CVATImageDataset") type represents a labeled dataset
consisting of images and their associated tags and object detections stored in
[CVAT image format](https://github.com/opencv/cvat).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels.xml

```

where `labels.xml` is an XML file in the following format:

```python
<?xml version="1.0" encoding="utf-8"?>
<annotations>
    <version>1.1</version>
    <meta>
        <task>
            <id>0</id>
            <name>task-name</name>
            <size>51</size>
            <mode>annotation</mode>
            <overlap></overlap>
            <bugtracker></bugtracker>
            <flipped>False</flipped>
            <created>2017-11-20 11:51:51.000000+00:00</created>
            <updated>2017-11-20 11:51:51.000000+00:00</updated>
            <labels>
                <label>
                    <name>car</name>
                    <attributes>
                        <attribute>
                            <name>type</name>
                            <values>coupe\\nsedan\\ntruck</values>
                        </attribute>
                        ...
                    </attributes>
                </label>
                <label>
                    <name>traffic_line</name>
                    <attributes>
                        <attribute>
                            <name>color</name>
                            <values>white\\nyellow</values>
                        </attribute>
                        ...
                    </attributes>
                </label>
                ...
            </labels>
        </task>
        <segments>
            <segment>
                <id>0</id>
                <start>0</start>
                <stop>50</stop>
                <url></url>
            </segment>
        </segments>
        <owner>
            <username></username>
            <email></email>
        </owner>
        <dumped>2017-11-20 11:51:51.000000+00:00</dumped>
    </meta>
    <image id="0" name="<uuid1>.<ext>" width="640" height="480">
        <tag label="urban"></tag>
        ...
        <box label="car" xtl="100" ytl="50" xbr="325" ybr="190" occluded="0">
            <attribute name="type">sedan</attribute>
            ...
        </box>
        ...
        <polygon label="car" points="561.30,916.23;561.30,842.77;...;560.20,966.67" occluded="0">
            <attribute name="make">Honda</attribute>
            ...
        </polygon>
        ...
        <polyline label="traffic_line" points="462.10,0.00;126.80,1200.00" occluded="0">
            <attribute name="color">yellow</attribute>
            ...
        </polyline>
        ...
        <points label="wheel" points="574.90,939.48;1170.16,907.90;...;600.16,459.48" occluded="0">
            <attribute name="location">front_driver_side</attribute>
            ...
        </points>
        ...
    </image>
    ...
    <image id="50" name="<uuid51>.<ext>" width="640" height="480">
        ...
    </image>
</annotations>

```

Unlabeled images have no corresponding `image` tag in `labels.xml`.

The `name` field of the `<image>` tags in the labels file encodes the location
of the corresponding images, which can be any of the following:

- The filename of an image in the `data/` folder

- A relative path like `path/to/filename.ext` specifying the relative path to
the image in a nested subfolder of `data/`

- An absolute path to an image, which may or may not be in the `data/` folder

Note

See [`CVATImageDatasetExporter`](../api/fiftyone.utils.cvat.html#fiftyone.utils.cvat.CVATImageDatasetExporter "fiftyone.utils.cvat.CVATImageDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a CVAT image dataset in the above format
as follows:

You can also perform labels-only exports of CVAT-formatted labels by providing
the `labels_path` parameter instead of `export_dir`:

## CVATVideoDataset [¶](\#cvatvideodataset "Permalink to this headline")

Supported label types

[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"), [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints")

The [`fiftyone.types.CVATVideoDataset`](../api/fiftyone.types.html#fiftyone.types.CVATVideoDataset "fiftyone.types.CVATVideoDataset") type represents a labeled dataset
consisting of videos and their associated object detections stored in
[CVAT video format](https://github.com/opencv/cvat).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels/
        <uuid1>.xml
        <uuid2>.xml
        ...

```

where the labels XML files are stored in the following format:

```python
<?xml version="1.0" encoding="utf-8"?>
<annotations>
    <version>1.1</version>
    <meta>
        <task>
            <id>task-id</id>
            <name>task-name</name>
            <size>51</size>
            <mode>interpolation</mode>
            <overlap></overlap>
            <bugtracker></bugtracker>
            <flipped>False</flipped>
            <created>2017-11-20 11:51:51.000000+00:00</created>
            <updated>2017-11-20 11:51:51.000000+00:00</updated>
            <labels>
                <label>
                    <name>car</name>
                    <attributes>
                        <attribute>
                            <name>type</name>
                            <values>coupe\\nsedan\\ntruck</values>
                        </attribute>
                        ...
                    </attributes>
                </label>
                <label>
                    <name>traffic_line</name>
                    <attributes>
                        <attribute>
                            <name>color</name>
                            <values>white\\nyellow</values>
                        </attribute>
                        ...
                    </attributes>
                </label>
                ...
            </labels>
        </task>
        <segments>
            <segment>
                <id>0</id>
                <start>0</start>
                <stop>50</stop>
                <url></url>
            </segment>
        </segments>
        <owner>
            <username></username>
            <email></email>
        </owner>
        <original_size>
            <width>640</width>
            <height>480</height>
        </original_size>
        <dumped>2017-11-20 11:51:51.000000+00:00</dumped>
    </meta>
    <track id="0" label="car">
        <box frame="0" xtl="100" ytl="50" xbr="325" ybr="190" outside="0" occluded="0" keyframe="1">
            <attribute name="type">sedan</attribute>
            ...
        </box>
        ...
    </track>
    <track id="1" label="car">
        <polygon frame="0" points="561.30,916.23;561.30,842.77;...;560.20,966.67" outside="0" occluded="0" keyframe="1">
            <attribute name="make">Honda</attribute>
            ...
        </polygon>
        ...
    </track>
    ...
    <track id="10" label="traffic_line">
        <polyline frame="10" points="462.10,0.00;126.80,1200.00" outside="0" occluded="0" keyframe="1">
            <attribute name="color">yellow</attribute>
            ...
        </polyline>
        ...
    </track>
    ...
    <track id="88" label="wheel">
        <points frame="176" points="574.90,939.48;1170.16,907.90;...;600.16,459.48" outside="0" occluded="0" keyframe="1">
            <attribute name="location">front_driver_side</attribute>
            ...
        </points>
        ...
    </track>
</annotations>

```

Unlabeled videos have no corresponding file in `labels/`.

Note

See [`CVATVideoDatasetExporter`](../api/fiftyone.utils.cvat.html#fiftyone.utils.cvat.CVATVideoDatasetExporter "fiftyone.utils.cvat.CVATVideoDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a CVAT video dataset in the above format
as follows:

You can also perform labels-only exports of CVAT-formatted labels by providing
the `labels_path` parameter instead of `export_dir`:

## FiftyOneImageLabelsDataset [¶](\#fiftyoneimagelabelsdataset "Permalink to this headline")

Supported label types

[`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications"), [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"), [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints")

The [`fiftyone.types.FiftyOneImageLabelsDataset`](../api/fiftyone.types.html#fiftyone.types.FiftyOneImageLabelsDataset "fiftyone.types.FiftyOneImageLabelsDataset") type represents a
labeled dataset consisting of images and their associated multitask predictions
stored in
[ETA ImageLabels format](https://github.com/voxel51/eta/blob/develop/docs/image_labels_guide.md).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels/
        <uuid1>.json
        <uuid2>.json
        ...
    manifest.json

```

where `manifest.json` is a JSON file in the following format:

```python
{
    "type": "eta.core.datasets.LabeledImageDataset",
    "description": "",
    "index": [\
        {\
            "data": "data/<uuid1>.<ext>",\
            "labels": "labels/<uuid1>.json"\
        },\
        {\
            "data": "data/<uuid2>.<ext>",\
            "labels": "labels/<uuid2>.json"\
        },\
        ...\
    ]
}

```

and where each labels JSON file is stored in
[ETA ImageLabels format](https://github.com/voxel51/eta/blob/develop/docs/image_labels_guide.md).

For unlabeled images, an empty `eta.core.image.ImageLabels` file is stored.

Note

See [`FiftyOneImageLabelsDatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.FiftyOneImageLabelsDatasetExporter "fiftyone.utils.data.exporters.FiftyOneImageLabelsDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as an image labels dataset in the above
format as follows:

## FiftyOneVideoLabelsDataset [¶](\#fiftyonevideolabelsdataset "Permalink to this headline")

Supported label types

[`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications"), [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`TemporalDetections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.TemporalDetections "fiftyone.core.labels.TemporalDetections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"), [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints")

The [`fiftyone.types.FiftyOneVideoLabelsDataset`](../api/fiftyone.types.html#fiftyone.types.FiftyOneVideoLabelsDataset "fiftyone.types.FiftyOneVideoLabelsDataset") type represents a
labeled dataset consisting of videos and their associated labels stored in
[ETA VideoLabels format](https://github.com/voxel51/eta/blob/develop/docs/video_labels_guide.md).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <uuid1>.<ext>
        <uuid2>.<ext>
        ...
    labels/
        <uuid1>.json
        <uuid2>.json
        ...
    manifest.json

```

where `manifest.json` is a JSON file in the following format:

```python
{
    "type": "eta.core.datasets.LabeledVideoDataset",
    "description": "",
    "index": [\
        {\
            "data": "data/<uuid1>.<ext>",\
            "labels": "labels/<uuid1>.json"\
        },\
        {\
            "data": "data/<uuid2>.<ext>",\
            "labels": "labels/<uuid2>.json"\
        },\
        ...\
    ]
}

```

and where each labels JSON file is stored in
[ETA VideoLabels format](https://github.com/voxel51/eta/blob/develop/docs/video_labels_guide.md).

For unlabeled videos, an empty `eta.core.video.VideoLabels` file is stored.

Note

See [`FiftyOneVideoLabelsDatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.FiftyOneVideoLabelsDatasetExporter "fiftyone.utils.data.exporters.FiftyOneVideoLabelsDatasetExporter")
for parameters that can be passed to methods like
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")
to customize the export of datasets of this type.

You can export a FiftyOne dataset as a video labels dataset in the above format
as follows:

## BDDDataset [¶](\#bdddataset "Permalink to this headline")

Supported label types

[`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications"), [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines")

The [`fiftyone.types.BDDDataset`](../api/fiftyone.types.html#fiftyone.types.BDDDataset "fiftyone.types.BDDDataset") type represents a labeled dataset
consisting of images and their associated multitask predictions saved in
[Berkeley DeepDrive (BDD) format](https://bdd-data.berkeley.edu).

Datasets of this type are exported in the following format:

```python
<dataset_dir>/
    data/
        <filename0>.<ext>
        <filename1>.<ext>
        ...
    labels.json

```

where `labels.json` is a JSON file in the following format:

```python
[\
    {\
        "name": "<filename0>.<ext>",\
        "attributes": {\
            "scene": "city street",\
            "timeofday": "daytime",\
            "weather": "overcast"\
        },\
        "labels": [\
            {\
                "id": 0,\
                "category": "traffic sign",\
                "manualAttributes": true,\
                "manualShape": true,\
                "attributes": {\
                    "occluded": false,\
                    "trafficLightColor": "none",\
                    "truncated": false\
                },\
                "box2d": {\
                    "x1": 1000.698742,\
                    "x2": 1040.626872,\
                    "y1": 281.992415,\
                    "y2": 326.91156\
                },\
                "score": 0.95\
            },\
            ...\
            {\
                "id": 34,\
                "category": "drivable area",\
                "manualAttributes": true,\
                "manualShape": true,\
                "attributes": {\
                    "areaType": "direct"\
                },\
                "poly2d": [\
                    {\
                        "types": "LLLLCCC",\
                        "closed": true,\
                        "vertices": [\
                            [241.143645, 697.923453],\
                            [541.525255, 380.564983],\
                            ...\
                        ]\
                    }\
                ],\
                "score": 0.87\
            },\
            ...\
            {\
                "id": 109356,\
                "category": "lane",\
                "attributes": {\
                    "laneDirection": "parallel",\
                    "laneStyle": "dashed",\
                    "laneType": "single white"\
                },\
                "manualShape": true,\
                "manualAttributes": true,\
                "poly2d": [\
                    {\
                        "types": "LL",\
                        "closed": false,\
                        "vertices": [\
                            [492.879546, 331.939543],\
                            [0, 471.076658],\
                            ...\
                        ]\
                    }\
                ],\
                "score": 0.98\
            },\
            ...\
        }\
    }\
    ...\
]\
\
```\
\
Unlabeled images have no corresponding entry in `labels.json`.\
\
The `name` attribute of the labels file encodes the location of the\
corresponding images, which can be any of the following:\
\
- The filename of an image in the `data/` folder\
\
- A relative path like `path/to/filename.ext` specifying the relative path to\
the image in a nested subfolder of `data/`\
\
- An absolute path to an image, which may or may not be in the `data/` folder\
\
\
Note\
\
See [`BDDDatasetExporter`](../api/fiftyone.utils.bdd.html#fiftyone.utils.bdd.BDDDatasetExporter "fiftyone.utils.bdd.BDDDatasetExporter")\
for parameters that can be passed to methods like\
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")\
to customize the export of datasets of this type.\
\
You can export a FiftyOne dataset as a BDD dataset in the above format as\
follows:\
\
You can also perform labels-only exports of BDD-formatted labels by providing\
the `labels_path` parameter instead of `export_dir`:\
\
## CSVDataset [¶](\#csvdataset "Permalink to this headline")\
\
The [`fiftyone.types.CSVDataset`](../api/fiftyone.types.html#fiftyone.types.CSVDataset "fiftyone.types.CSVDataset") type is a flexible CSV format that\
represents slice(s) of field values of a dataset as columns of a CSV file.\
\
Datasets of this type are exported in the following format:\
\
```\
<dataset_dir>/\
    data/\
        <filename1>.<ext>\
        <filename2>.<ext>\
        ...\
    labels.csv\
\
```\
\
where `labels.csv` is a CSV file in the following format:\
\
```\
field1,field2,field3,...\
value1,value2,value3,...\
value1,value2,value3,...\
...\
\
```\
\
where the columns of interest are specified via the `fields` parameter, and may\
contain any number of top-level or embedded fields such as strings, ints,\
floats, booleans, or lists of such values.\
\
List values are encoded as `"list,of,values"` with double quotes to escape the\
commas. Missing field values are encoded as empty cells.\
\
Note\
\
See [`CSVDatasetExporter`](../api/fiftyone.utils.csv.html#fiftyone.utils.csv.CSVDatasetExporter "fiftyone.utils.csv.CSVDatasetExporter") for\
parameters that can be passed to methods like\
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")\
to customize the export of datasets of this type.\
\
You can export a FiftyOne dataset as a CSV dataset in the above format as\
follows:\
\
You can also directly export a CSV file of field values and absolute media\
paths without exporting the actual media files by providing the `labels_path`\
parameter instead of `export_dir`:\
\
## GeoJSONDataset [¶](\#geojsondataset "Permalink to this headline")\
\
The [`fiftyone.types.GeoJSONDataset`](../api/fiftyone.types.html#fiftyone.types.GeoJSONDataset "fiftyone.types.GeoJSONDataset") type represents a dataset consisting\
of images or videos and their associated geolocation data and optional\
properties stored in [GeoJSON format](https://en.wikipedia.org/wiki/GeoJSON).\
\
Datasets of this type are exported in the following format:\
\
```\
<dataset_dir>/\
    data/\
        <filename1>.<ext>\
        <filename2>.<ext>\
        ...\
    labels.json\
\
```\
\
where `labels.json` is a GeoJSON file containing a `FeatureCollection` in\
the following format:\
\
```\
{\
    "type": "FeatureCollection",\
    "features": [\
        {\
            "type": "Feature",\
            "geometry": {\
                "type": "Point",\
                "coordinates": [\
                    -73.99496451958454,\
                    40.66338032487842\
                ]\
            },\
            "properties": {\
                "filename": <filename1>.<ext>,\
                ...\
            }\
        },\
        {\
            "type": "Feature",\
            "geometry": {\
                "type": "Point",\
                "coordinates": [\
                    -73.80992143421788,\
                    40.65611832778962\
                ]\
            },\
            "properties": {\
                "filename": <filename2>.<ext>,\
                ...\
            }\
        },\
        ...\
    ]\
}\
\
```\
\
where the `geometry` field may contain any valid GeoJSON geometry object, and\
the `filename` property encodes the name of the corresponding media in the\
`data/` folder. The `filename` property can also be an absolute path, which\
may or may not be in the `data/` folder.\
\
Samples with no location data will have a null `geometry` field.\
\
The `properties` field of each feature can contain additional labels for\
each sample.\
\
Note\
\
See [`GeoJSONDatasetExporter`](../api/fiftyone.utils.geojson.html#fiftyone.utils.geojson.GeoJSONDatasetExporter "fiftyone.utils.geojson.GeoJSONDatasetExporter")\
for parameters that can be passed to methods like\
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")\
to customize the export of datasets of this type.\
\
You can export a FiftyOne dataset as a GeoJSON dataset in the above format as\
follows:\
\
You can also perform labels-only exports of GeoJSON-formatted labels by\
providing the `labels_path` parameter instead of `export_dir`:\
\
## FiftyOneDataset [¶](\#fiftyonedataset "Permalink to this headline")\
\
The [`fiftyone.types.FiftyOneDataset`](../api/fiftyone.types.html#fiftyone.types.FiftyOneDataset "fiftyone.types.FiftyOneDataset") provides a disk representation of\
an entire [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") in a serialized JSON format along with its source media.\
\
Datasets of this type are exported in the following format:\
\
```\
<dataset_dir>/\
    metadata.json\
    samples.json\
    data/\
        <filename1>.<ext>\
        <filename2>.<ext>\
        ...\
    annotations/\
        <anno_key1>.json\
        <anno_key2>.json\
        ...\
    brain/\
        <brain_key1>.json\
        <brain_key2>.json\
        ...\
    evaluations/\
        <eval_key1>.json\
        <eval_key2>.json\
        ...\
\
```\
\
where `metadata.json` is a JSON file containing metadata associated with the\
dataset, `samples.json` is a JSON file containing a serialized representation\
of the samples in the dataset, `annotations/` contains any serialized\
[`AnnotationResults`](../api/fiftyone.core.annotation.html#fiftyone.core.annotation.AnnotationResults "fiftyone.core.annotation.AnnotationResults"), `brain/` contains any serialized [`BrainResults`](../api/fiftyone.core.brain.html#fiftyone.core.brain.BrainResults "fiftyone.core.brain.BrainResults"), and\
`evaluations/` contains any serialized [`EvaluationResults`](../api/fiftyone.core.evaluation.html#fiftyone.core.evaluation.EvaluationResults "fiftyone.core.evaluation.EvaluationResults").\
\
Video datasets have an additional `frames.json` file that contains a serialized\
representation of the frame labels for each video in the dataset.\
\
Note\
\
See [`FiftyOneDatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.FiftyOneDatasetExporter "fiftyone.utils.data.exporters.FiftyOneDatasetExporter")\
for parameters that can be passed to methods like\
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export")\
to customize the export of datasets of this type.\
\
You can export a FiftyOne dataset to disk in the above format as follows:\
\
You can export datasets in this this format without copying the source media\
files by including `export_media=False` in your call to\
[`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export").\
\
You can also pass `use_dirs=True` to export per-sample/frame JSON files rather\
than storing all samples/frames in single JSON files.\
\
By default, the absolute filepath of each image will be included in the export.\
However, if you want to re-import this dataset on a different machine with the\
source media files stored in a different root directory, you can include the\
optional `rel_dir` parameter to specify a common prefix to strip from each\
image’s filepath, and then provide the new `rel_dir` when\
[importing the dataset](dataset_creation/datasets.md#fiftyonedataset-import):\
\
Note\
\
Exporting in [`fiftyone.types.FiftyOneDataset`](../api/fiftyone.types.html#fiftyone.types.FiftyOneDataset "fiftyone.types.FiftyOneDataset") format as shown above\
using the `export_media=False` and `rel_dir` parameters is a convenient way\
to transfer datasets between work environments, since this enables you to\
store the media files wherever you wish in each environment and then simply\
provide the appropriate `rel_dir` value when\
[importing](dataset_creation/datasets.md#fiftyonedataset-import) the dataset into FiftyOne in a\
new environment.\
\
You can also pass in a `chunk_size` parameter to create nested directories of\
media files with a maximum number of files per directory. This can be useful\
when exporting large datasets to avoid filesystem limits on the number of files\
in a single directory.\
\
As an example, the following code exports a dataset with a maximum of 1000\
media files per directory:\
\
```\
import fiftyone as fo\
\
export_dir = "/path/for/fiftyone-dataset"\
\
# The dataset or view to export\
dataset_or_view = fo.load_dataset(...)\
\
# Export the dataset with a maximum of 1000 media files per directory\
dataset_or_view.export(\
    export_dir=export_dir,\
    dataset_type=fo.types.FiftyOneDataset,\
    chunk_size=1000,\
)\
\
```\
\
This will create a directory structure like the following:\
\
```\
<dataset_dir>/\
    metadata.json\
    samples.json\
    data/\
        data_0/\
            <filename1>.<ext>\
            <filename2>.<ext>\
            ...\
        data_1/\
            <filename1>.<ext>\
            <filename2>.<ext>\
        ...\
\
```\
\
## Custom formats [¶](\#custom-formats "Permalink to this headline")\
\
The [`export()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.export "fiftyone.core.collections.SampleCollection.export") method\
provides an optional `dataset_exporter` keyword argument that can be used to\
export a dataset using any [`DatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.DatasetExporter "fiftyone.utils.data.exporters.DatasetExporter") instance.\
\
This means that you can define your own [`DatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.DatasetExporter "fiftyone.utils.data.exporters.DatasetExporter") class and then export\
a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") in your custom format using the following recipe:\
\
```\
import fiftyone as fo\
\
# The dataset or view to export\
dataset_or_view = fo.load_dataset(...)\
\
# Create an instance of your custom dataset exporter\
exporter = CustomDatasetExporter(...)\
\
# Export the dataset\
dataset_or_view.export(dataset_exporter=exporter, ...)\
\
```\
\
You can also define a custom [`Dataset`](../api/fiftyone.types.html#fiftyone.types.Dataset "fiftyone.types.Dataset") type, which enables you to export\
datasets in your custom format using the following recipe:\
\
```\
import fiftyone as fo\
\
# The `fiftyone.types.Dataset` subclass for your custom dataset\
dataset_type = CustomDataset\
\
# The dataset or view to export\
dataset_or_view = fo.load_dataset(...)\
\
# Export the dataset\
dataset_or_view.export(dataset_type=dataset_type, ...)\
\
```\
\
### Writing a custom DatasetExporter [¶](\#writing-a-custom-datasetexporter "Permalink to this headline")\
\
[`DatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.DatasetExporter "fiftyone.utils.data.exporters.DatasetExporter") is an abstract interface; the concrete interface that you\
should implement is determined by the type of dataset that you are exporting.\
\
### Writing a custom Dataset type [¶](\#writing-a-custom-dataset-type "Permalink to this headline")\
\
FiftyOne provides the [`Dataset`](../api/fiftyone.types.html#fiftyone.types.Dataset "fiftyone.types.Dataset") type system so that dataset formats can be\
conveniently referenced by their type when reading/writing datasets on disk.\
\
The primary function of the [`Dataset`](../api/fiftyone.types.html#fiftyone.types.Dataset "fiftyone.types.Dataset") subclasses is to define the\
[`DatasetImporter`](../api/fiftyone.utils.data.importers.html#fiftyone.utils.data.importers.DatasetImporter "fiftyone.utils.data.importers.DatasetImporter") that should be used to read instances of the dataset from\
disk and the [`DatasetExporter`](../api/fiftyone.utils.data.exporters.html#fiftyone.utils.data.exporters.DatasetExporter "fiftyone.utils.data.exporters.DatasetExporter") that should be used to write instances of the\
dataset to disk.\
\
See [this page](dataset_creation/datasets.md#writing-a-custom-dataset-importer) for more information\
about defining custom [`DatasetImporter`](../api/fiftyone.utils.data.importers.html#fiftyone.utils.data.importers.DatasetImporter "fiftyone.utils.data.importers.DatasetImporter") classes.\
\
Custom dataset types can be declared by implementing the [`Dataset`](../api/fiftyone.types.html#fiftyone.types.Dataset "fiftyone.types.Dataset") subclass\
corresponding to the type of dataset that you are working with.\
\
