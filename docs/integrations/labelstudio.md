# Label Studio Integration [¶](\#label-studio-integration "Permalink to this headline")

[Label Studio](https://labelstud.io/) is a popular open-source data labeling
tool with a friendly UI. The integration between FiftyOne and Label Studio
allows you to easily upload your data directly from FiftyOne to Label Studio
for labeling.

You can get started with Label Studio through a simple pip install to get a
local server up and running. FiftyOne provides
[simple setup instructions](#label-studio-setup) that you can use to
specify the necessary account credentials and server endpoint to use.

Note

Did you know? You can request, manage, and import annotations from within
the FiftyOne App by installing the
[@voxel51/annotation](https://github.com/voxel51/fiftyone-plugins/tree/main/plugins/annotation)
plugin!

FiftyOne provides an API to create projects, upload data, define label schemas,
and download annotations using Label Studio, all programmatically in Python.
All of the following label types are supported for image datasets:

- [Classification](../fiftyone_concepts/using_datasets.md#classification)

- [Multilabel classification](../fiftyone_concepts/using_datasets.md#multilabel-classification)

- [Detections](../fiftyone_concepts/using_datasets.md#object-detection)

- [Instance segmentations](../fiftyone_concepts/using_datasets.md#instance-segmentation)

- [Polygons and polylines](../fiftyone_concepts/using_datasets.md#polylines)

- [Keypoints](../fiftyone_concepts/using_datasets.md#keypoints)

- [Scalar fields](../fiftyone_concepts/using_datasets.md#adding-sample-fields)

- [Semantic segmentation](../fiftyone_concepts/using_datasets.md#semantic-segmentation)


## Basic recipe [¶](\#basic-recipe "Permalink to this headline")

The basic workflow to use Label Studio to add or edit labels on your FiftyOne
datasets is as follows:

1. Load a [labeled or unlabeled dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) into FiftyOne

2. Explore the dataset using the [App](../fiftyone_concepts/app.md#fiftyone-app) or
[dataset views](../fiftyone_concepts/using_views.md#using-views) to locate either unlabeled samples that
you wish to annotate or labeled samples whose annotations you want to edit

3. Use the
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate")
method on your dataset or view to upload the samples and optionally their
existing labels to Label Studio by setting the parameter
`backend="labelstudio"`

4. In Label Studio, perform the necessary annotation work

5. Back in FiftyOne, load your dataset and use the
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
method to merge the annotations back into your FiftyOne dataset

6. If desired, delete the Label Studio tasks and the record of the annotation
run from your FiftyOne dataset


The example below demonstrates this workflow.

Note

You must start by installing and setting up Label Studio as described in
[this section](#label-studio-setup).

Note that you can also store your credentials to avoid entering them
manually each time you interact with Label Studio.

First, we create the annotation tasks in Label Studio:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

# Step 1: Load your data into FiftyOne

dataset = foz.load_zoo_dataset(
    "quickstart", dataset_name="ls-annotation-example"
)
dataset.persistent = True

dataset.evaluate_detections(
    "predictions", gt_field="ground_truth", eval_key="eval"
)

# Step 2: Locate a subset of your data requiring annotation

# Create a view that contains only high confidence false positive model
# predictions, with samples containing the most false positives first
most_fp_view = (
    dataset
    .filter_labels("predictions", (F("confidence") > 0.8) & (F("eval") == "fp"))
    .sort_by(F("predictions.detections").length(), reverse=True)
)

# Retrieve the sample with the most high confidence false positives
sample_id = most_fp_view.first().id
view = dataset.select(sample_id)

# Step 3: Send samples to Label Studio

# A unique identifier for this run
anno_key = "labelstudio_basic_recipe"

label_schema = {
    "new_ground_truth": {
        "type": "detections",
        "classes": dataset.distinct("ground_truth.detections.label"),
    },
}

view.annotate(
    anno_key,
    backend="labelstudio",
    label_schema=label_schema,
    launch_editor=True,
)
print(dataset.get_annotation_info(anno_key))

# Step 4: Perform annotation in Label Studio and save the tasks

```

Then, once the annotation work is complete, we merge the annotations back into
FiftyOne:

```python
import fiftyone as fo

anno_key = "labelstudio_basic_recipe"

# Step 5: Merge annotations back into FiftyOne dataset

dataset = fo.load_dataset("ls-annotation-example")
dataset.load_annotations(anno_key)

# Load the view that was annotated in the App
view = dataset.load_annotation_view(anno_key)
session = fo.launch_app(view=view)

# Step 6: Cleanup

# Delete tasks from Label Studio
results = dataset.load_annotation_results(anno_key)
results.cleanup()

# Delete run record (not the labels) from FiftyOne
dataset.delete_annotation_run(anno_key)

```

## Setup [¶](\#setup "Permalink to this headline")

The easiest way to get started with
[Label Studio](https://github.com/heartexlabs/label-studio) is to install
it locally and create an account.

```python
pip install label-studio

# Launch it!
label-studio

```

### Installing the Label Studio client [¶](\#installing-the-label-studio-client "Permalink to this headline")

In order to use the Label Studio backend, you must install the
[Label Studio Python SDK](https://github.com/heartexlabs/label-studio-sdk):

```python
pip install label-studio-sdk

```

### Using the Label Studio backend [¶](\#using-the-label-studio-backend "Permalink to this headline")

By default, calling
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") will
use the [CVAT backend](cvat.md#cvat-integration).

To use the Label Studio backend, simply set the optional `backend` parameter of
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") to
`"labelstudio"`:

```python
view.annotate(anno_key, backend="labelstudio", ...)

```

Alternatively, you can permanently configure FiftyOne to use the Label Studio
backend by setting the `FIFTYONE_ANNOTATION_DEFAULT_BACKEND` environment
variable:

```python
export FIFTYONE_ANNOTATION_DEFAULT_BACKEND=labelstudio

```

or by setting the `default_backend` parameter of your
[annotation config](../fiftyone_concepts/annotation.md#annotation-config) located at
`~/.fiftyone/annotation_config.json`:

```python
{
    "default_backend": "labelstudio"
}

```

### Authentication [¶](\#authentication "Permalink to this headline")

In order to connect to a Label Studio server, you must provide your API key,
which can be done in a variety of ways.

**Environment variables (recommended)**

The recommended way to configure your Label Studio API key is to store it in
the `FIFTYONE_LABELSTUDIO_API_KEY` environment variable. This is automatically
accessed by FiftyOne whenever a connection to Label Studio is made.

```python
export FIFTYONE_LABELSTUDIO_API_KEY=...

```

**FiftyOne annotation config**

You can also store your credentials in your
[annotation config](../fiftyone_concepts/annotation.md#annotation-config) located at
`~/.fiftyone/annotation_config.json`:

```python
{
    "backends": {
        "labelstudio": {
            "api_key": ...,
        }
    }
}

```

Note that this file will not exist until you create it.

**Keyword arguments**

You can manually provide your API key as a keyword argument each time you call
methods like
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") and
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
that require connections to Label Studio:

```python
view.annotate(
    anno_key,
    backend="labelstudio",
    label_field="ground_truth",
    api_key=...,
)

```

**Command line prompt**

If you have not stored your API key via another method, you will be prompted to
enter it interactively in your shell each time you call a method that requires
a connection to Label Studio:

```python
view.annotate(
    anno_key,
    backend="labelstudio",
    label_field="ground_truth",
    launch_editor=True,
)

```

```python
Please enter your API key.
You can avoid this in the future by setting your `FIFTYONE_LABELSTUDIO_API_KEY` environment variable.
API key: ...

```

### Server URL [¶](\#server-url "Permalink to this headline")

You can configure the URL to the desired Label Studio server in any of the
following ways:

- Set the `FIFTYONE_LABELSTUDIO_URL` environment variable:


```python
export FIFTYONE_LABELSTUDIO_URL=http://localhost:8080

```

- Store the `url` of your server in your
[annotation config](../fiftyone_concepts/annotation.md#annotation-config) at
`~/.fiftyone/annotation_config.json`:


```python
{
    "backends": {
        "labelstudio": {
            "url": "http://localhost:8080"
        }
    }
}

```

- Pass the `url` parameter manually each time you call
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"):


```python
view.annotate(
    anno_key,
    backend="labelstudio",
    label_field="ground_truth",
    url="http://localhost:8080",
    api_key=...,
)

```

### Configuring local file storage [¶](\#configuring-local-file-storage "Permalink to this headline")

If you are using FiftyOne on the same machine that is hosting Label Studio,
then you can make use of the
[local storage feature](https://labelstud.io/guide/storage#Local-storage)
of Label Studio to avoid needing to copy your media.

To enable this, you just need to configure the
`LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT` and
`LABEL_STUDIO_LOCAL_FILES_SERVING_ENABLED` environment variables as defined in
[the documentation](https://labelstud.io/guide/storage#Prerequisites-2).

Then when you request annotations, if all of the samples in your [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or
[`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") reside in a subdirectory of the
`LABEL_STUDIO_LOCAL_FILES_DOCUMENT_ROOT`, the media will not be copied over and
only filepaths for you media will be used to create the Label Studio project.

## Requesting annotations [¶](\#requesting-annotations "Permalink to this headline")

Use the
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") method
to send the samples and optionally existing labels in a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or
[`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") to Label Studio for annotation.

The basic syntax is:

```python
anno_key = "..."
view.annotate(anno_key, backend="labelstudio", ...)

```

The `anno_key` argument defines a unique identifier for the annotation run, and
you will provide it to methods like
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations"),
[`get_annotation_info()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations"),
[`load_annotation_results()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotation_results "fiftyone.core.collections.SampleCollection.load_annotation_results"),
[`rename_annotation_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.rename_annotation_run "fiftyone.core.collections.SampleCollection.rename_annotation_run"), and
[`delete_annotation_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.delete_annotation_run "fiftyone.core.collections.SampleCollection.delete_annotation_run")
to manage the run in the future.

Note

Calling
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate")
will upload the source media files to the Label Studio server.

In addition,
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate")
provides various parameters that you can use to customize the annotation tasks
that you wish to be performed.

The following parameters are supported by all annotation backends:

- **backend** ( _None_): the annotation backend to use. Use `"labelstudio"`
for the Label Studio backend. The supported values are
`fiftyone.annotation_config.backends.keys()` and the default is
`fiftyone.annotation_config.default_backend`

- **media\_field** ( _“filepath”_): the sample field containing the path to the
source media to upload

- **launch\_editor** ( _False_): whether to launch the annotation backend’s
editor after uploading the samples


The following parameters allow you to configure the labeling schema to use for
your annotation tasks. See [this section](#label-studio-label-schema) for
more details:

- **label\_schema** ( _None_): a dictionary defining the label schema to use.
If this argument is provided, it takes precedence over `label_field` and
`label_type`

- **label\_field** ( _None_): a string indicating a new or existing label field
to annotate

- **label\_type** ( _None_): a string indicating the type of labels to
annotate. The possible label types are:


  - `"classification"`: a single classification stored in
    [`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification") fields

  - `"classifications"`: multilabel classifications stored in
    [`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications") fields

  - `"detections"`: object detections stored in [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") fields

  - `"instances"`: instance segmentations stored in [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") fields
    with their [`mask`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detection.mask "fiftyone.core.labels.Detection.mask")
    attributes populated

  - `"polylines"`: polylines stored in [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines") fields with their
    [`filled`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polyline.filled "fiftyone.core.labels.Polyline.filled") attributes set to
    `False`

  - `"polygons"`: polygons stored in [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines") fields with their
    [`filled`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polyline.filled "fiftyone.core.labels.Polyline.filled") attributes set to
    `True`

  - `"keypoints"`: keypoints stored in [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints") fields

  - `"segmentation"`: semantic segmentations stored in [`Segmentation`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Segmentation "fiftyone.core.labels.Segmentation")
    fields


All new label fields must have their type specified via this argument or in
`label_schema`

- **classes** ( _None_): a list of strings indicating the class options for
`label_field` or all fields in `label_schema` without classes specified.
All new label fields must have a class list provided via one of the
supported methods. For existing label fields, if classes are not provided
by this argument nor `label_schema`, they are parsed from
[`Dataset.classes`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.classes "fiftyone.core.dataset.Dataset.classes") or
[`Dataset.default_classes`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.default_classes "fiftyone.core.dataset.Dataset.default_classes")

- **mask\_targets** ( _None_): a dict mapping pixel values to semantic label
strings. Only applicable when annotating semantic segmentations


In addition, the following Label Studio-specific parameters from
[`LabelStudioBackendConfig`](../api/fiftyone.utils.labelstudio.html#fiftyone.utils.labelstudio.LabelStudioBackendConfig "fiftyone.utils.labelstudio.LabelStudioBackendConfig")
can also be provided:

- **project\_name** ( _None_): a name for the Label Studio project that will be
created. The default is `"FiftyOne_<dataset_name>"`


### Label schema [¶](\#label-schema "Permalink to this headline")

The `label_schema`, `label_field`, `label_type`, `classes`, and `mask_targets`
parameters to
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") allow
you to define the annotation schema that you wish to be used.

The label schema may define new label field(s) that you wish to populate, and
it may also include existing label field(s), in which case you can add, delete,
or edit the existing labels on your FiftyOne dataset.

The `label_schema` argument is the most flexible way to define how to construct
tasks in Label Studio. In its most verbose form, it is a dictionary that
defines the label type, annotation type, and possible classes for each label
field:

```python
anno_key = "..."

label_schema = {
    "new_field": {
        "type": "detections",
        "classes": ["class1", "class2"],
    },
    "existing_field": {
        "classes": ["class3", "class4"],
    },
}

dataset.annotate(anno_key, backend="labelstudio", label_schema=label_schema)

```

Alternatively, if you are only editing or creating a single label field, you
can use the `label_field`, `label_type`, `classes`, and
`mask_targets` parameters to specify the components of the label schema
individually:

```python
anno_key = "..."

label_field = "new_field",
label_type = "detections"
classes = ["class1", "class2"]

dataset.annotate(
    anno_key,
    backend="labelstudio",
    label_field=label_field,
    label_type=label_type,
    classes=classes,
)

```

When you are annotating existing label fields, you can omit some of these
parameters from
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"), as
FiftyOne can infer the appropriate values to use:

- **label\_type**: if omitted, the [`Label`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") type of the field will be used to
infer the appropriate value for this parameter

- **classes**: if omitted for a non-semantic segmentation field, the class
lists from the [`classes`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.classes "fiftyone.core.dataset.Dataset.classes") or
[`default_classes`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.default_classes "fiftyone.core.dataset.Dataset.default_classes")
properties of your dataset will be used, if available. Otherwise, the
observed labels on your dataset will be used to construct a classes list

- **mask\_targets**: if omitted for a semantic segmentation field, the mask
targets from the
[`mask_targets`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.mask_targets "fiftyone.core.dataset.Dataset.mask_targets") or
[`default_mask_targets`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.default_mask_targets "fiftyone.core.dataset.Dataset.default_mask_targets")
properties of your dataset will be used, if available


### Label attributes [¶](\#label-attributes "Permalink to this headline")

Warning

The Label Studio integration does not yet support
[annotating label attributes](../fiftyone_concepts/annotation.md#annotation-label-attributes).

## Loading annotations [¶](\#loading-annotations "Permalink to this headline")

After your annotations tasks in the annotation backend are complete, you can
use the
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
method to download them and merge them back into your FiftyOne dataset.

```python
view.load_annotations(anno_key)

```

The `anno_key` parameter is the unique identifier for the annotation run that
you provided when calling
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"). You
can use
[`list_annotation_runs()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.list_annotation_runs "fiftyone.core.collections.SampleCollection.list_annotation_runs")
to see the available keys on a dataset.

Note

By default, calling
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
will not delete any information for the run from the annotation backend.

However, you can pass `cleanup=True` to delete all information associated
with the run from the backend after the annotations are downloaded.

You can use the optional `dest_field` parameter to override the task’s
label schema and instead load annotations into different field name(s) of your
dataset. This can be useful, for example, when editing existing annotations, if
you would like to do a before/after comparison of the edits that you import. If
the annotation run involves multiple fields, `dest_field` should be a
dictionary mapping label schema field names to destination field names.

## Managing annotation runs [¶](\#managing-annotation-runs "Permalink to this headline")

FiftyOne provides a variety of methods that you can use to manage in-progress
or completed annotation runs.

For example, you can call
[`list_annotation_runs()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.list_annotation_runs "fiftyone.core.collections.SampleCollection.list_annotation_runs")
to see the available annotation keys on a dataset:

```python
dataset.list_annotation_runs()

```

Or, you can use
[`get_annotation_info()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.get_annotation_info "fiftyone.core.collections.SampleCollection.get_annotation_info")
to retrieve information about the configuration of an annotation run:

```python
info = dataset.get_annotation_info(anno_key)
print(info)

```

Use [`load_annotation_results()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotation_results "fiftyone.core.collections.SampleCollection.load_annotation_results")
to load the [`AnnotationResults`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationResults "fiftyone.utils.annotations.AnnotationResults")
instance for an annotation run.

All results objects provide a [`cleanup()`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationResults.cleanup "fiftyone.utils.annotations.AnnotationResults.cleanup")
method that you can use to delete all information associated with a run from
the annotation backend.

```python
results = dataset.load_annotation_results(anno_key)
results.cleanup()

```

In addition, the
[`AnnotationResults`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationResults "fiftyone.utils.annotations.AnnotationResults")
subclasses for each backend may provide additional utilities such as support
for programmatically monitoring the status of the annotation tasks in the run.

You can use
[`rename_annotation_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.rename_annotation_run "fiftyone.core.collections.SampleCollection.rename_annotation_run")
to rename the annotation key associated with an existing annotation run:

```python
dataset.rename_annotation_run(anno_key, new_anno_key)

```

Finally, you can use
[`delete_annotation_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.delete_annotation_run "fiftyone.core.collections.SampleCollection.delete_annotation_run")
to delete the record of an annotation run from your FiftyOne dataset:

```python
dataset.delete_annotation_run(anno_key)

```

Note

Calling
[`delete_annotation_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.delete_annotation_run "fiftyone.core.collections.SampleCollection.delete_annotation_run")
only deletes the **record** of the annotation run from your FiftyOne
dataset; it will not delete any annotations loaded onto your dataset via
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations"),
nor will it delete any associated information from the annotation backend.

## Annotating videos [¶](\#annotating-videos "Permalink to this headline")

Warning

The Label Studio integration does not currently support annotating videos.

## Acknowledgements [¶](\#acknowledgements "Permalink to this headline")

Note

Special thanks to [Rustem Galiullin](https://github.com/Rusteam),
[Ganesh Tata](https://github.com/tataganesh), and
[Emil Zakirov](https://github.com/bonlime) for building this integration!

