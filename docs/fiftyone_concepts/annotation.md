# Annotating Datasets [¶](\#annotating-datasets "Permalink to this headline")

FiftyOne provides a powerful annotation API that makes it easy to add or edit
labels on your [datasets](using_datasets.md#using-datasets) or specific
[views](using_views.md#using-views) into them.

Note

Did you know? You can request, manage, and import annotations from within
the FiftyOne App by installing the
[@voxel51/annotation](https://github.com/voxel51/fiftyone-plugins/tree/main/plugins/annotation)
plugin!

Note

Check out [this tutorial](../tutorials/cvat_annotation.ipynb) to see an
example workflow that uses the annotation API to create, delete, and fix
annotations on a FiftyOne dataset.

## Basic recipe [¶](\#basic-recipe "Permalink to this headline")

The basic workflow to use the annotation API to add or edit labels on your
FiftyOne datasets is as follows:

1. Load a [labeled or unlabeled dataset](dataset_creation/index.md#loading-datasets) into FiftyOne

2. Explore the dataset using the [App](app.md#fiftyone-app) or
[dataset views](using_views.md#using-views) to locate either unlabeled samples that
you wish to annotate or labeled samples whose annotations you want to edit

3. Use the
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate")
method on your dataset or view to upload the samples and optionally their
existing labels to the annotation backend

4. In the annotation tool, perform the necessary annotation work

5. Back in FiftyOne, load your dataset and use the
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
method to merge the annotations back into your FiftyOne dataset

6. If desired, delete the annotation tasks and the record of the annotation run
from your FiftyOne dataset


The example below demonstrates this workflow using the default
[CVAT backend](../integrations/cvat.md#cvat-integration).

Note

You must create an account at [app.cvat.ai](https://app.cvat.ai) in order to
run this example.

Note that you can store your credentials as described in
[this section](../integrations/cvat.md#cvat-setup) to avoid entering them manually each time
you interact with CVAT.

First, we create the annotation tasks:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

# Step 1: Load your data into FiftyOne

dataset = foz.load_zoo_dataset(
    "quickstart", dataset_name="cvat-annotation-example"
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

# Let's edit the ground truth annotations for the sample with the most
# high confidence false positives
sample_id = most_fp_view.first().id
view = dataset.select(sample_id)

# Step 3: Send samples to CVAT

# A unique identifier for this run
anno_key = "cvat_basic_recipe"

view.annotate(
    anno_key,
    label_field="ground_truth",
    attributes=["iscrowd"],
    launch_editor=True,
)
print(dataset.get_annotation_info(anno_key))

# Step 4: Perform annotation in CVAT and save the tasks

```

Then, once the annotation work is complete, we merge the annotations back into
FiftyOne:

```python
import fiftyone as fo

anno_key = "cvat_basic_recipe"

# Step 5: Merge annotations back into FiftyOne dataset

dataset = fo.load_dataset("cvat-annotation-example")
dataset.load_annotations(anno_key)

# Load the view that was annotated in the App
view = dataset.load_annotation_view(anno_key)
session = fo.launch_app(view=view)

# Step 6: Cleanup

# Delete tasks from CVAT
results = dataset.load_annotation_results(anno_key)
results.cleanup()

# Delete run record (not the labels) from FiftyOne
dataset.delete_annotation_run(anno_key)

```

Note

Check out [this page](../integrations/cvat.md#cvat-examples) to see a variety of common
annotation patterns using the CVAT backend to illustrate the full process.

## Setup [¶](\#setup "Permalink to this headline")

By default, all annotation is performed via [app.cvat.ai](https://app.cvat.ai),
which simply requires that you create an account and then configure your
username and password credentials.

However, you can configure FiftyOne to use a
[self-hosted CVAT server](../integrations/cvat.md#cvat-self-hosted-server), or you can even use a
completely [custom backend](#custom-annotation-backend).

Note

See [this page](../integrations/cvat.md#cvat-setup) for CVAT-specific setup instructions.

### Changing your annotation backend [¶](\#changing-your-annotation-backend "Permalink to this headline")

You can use a specific backend for a particular annotation run by passing the
`backend` parameter to
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"):

```python
view.annotate(..., backend="<backend>", ...)

```

Alternatively, you can change your default annotation backend for an entire
session by setting the `FIFTYONE_ANNOTATION_DEFAULT_BACKEND` environment
variable.

```python
export FIFTYONE_ANNOTATION_DEFAULT_BACKEND=<backend>

```

Finally, you can permanently change your default annotation backend by updating
the `default_backend` key of your [annotation config](#annotation-config)
at `~/.fiftyone/annotation_config.json`:

```python
{
    "default_backend": "<backend>",
    "backends": {
        "<backend>": {...},
        ...
    }
}

```

### Configuring your backend [¶](\#configuring-your-backend "Permalink to this headline")

Annotation backends may be configured in a variety of backend-specific ways,
which you can see by inspecting the parameters of a backend’s associated
[`AnnotationBackendConfig`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackendConfig "fiftyone.utils.annotations.AnnotationBackendConfig") class.

The relevant classes for the builtin annotation backends are:

- `"cvat"`: [`fiftyone.utils.cvat.CVATBackendConfig`](../api/fiftyone.utils.cvat.html#fiftyone.utils.cvat.CVATBackendConfig "fiftyone.utils.cvat.CVATBackendConfig")

- `"labelstudio"`: [`fiftyone.utils.labelstudio.LabelStudioBackendConfig`](../api/fiftyone.utils.labelstudio.html#fiftyone.utils.labelstudio.LabelStudioBackendConfig "fiftyone.utils.labelstudio.LabelStudioBackendConfig")

- `"labelbox"`: [`fiftyone.utils.labelbox.LabelboxBackendConfig`](../api/fiftyone.utils.labelbox.html#fiftyone.utils.labelbox.LabelboxBackendConfig "fiftyone.utils.labelbox.LabelboxBackendConfig")


You can configure an annotation backend’s parameters for a specific run by
simply passing supported config parameters as keyword arguments each time you call
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"):

```python
view.annotate(
    ...
    backend="cvat",
    url="http://localhost:8080",
    username=...,
    password=...,
)

```

Alternatively, you can more permanently configure your backend(s) via your
[annotation config](#annotation-config).

## Annotation config [¶](\#annotation-config "Permalink to this headline")

FiftyOne provides an annotation config that you can use to either temporarily
or permanently configure the behavior of the annotation API.

### Viewing your config [¶](\#viewing-your-config "Permalink to this headline")

You can print your current annotation config at any time via the Python library
and the CLI:

Note

If you have customized your annotation config via any of the methods
described below, printing your config is a convenient way to ensure that
the changes you made have taken effect as you expected.

### Modifying your config [¶](\#modifying-your-config "Permalink to this headline")

You can modify your annotation config in a variety of ways. The following
sections describe these options in detail.

#### Order of precedence [¶](\#order-of-precedence "Permalink to this headline")

The following order of precedence is used to assign values to your annotation
config settings as runtime:

1. Config settings applied at runtime by directly editing
`fiftyone.annotation_config`

2. `FIFTYONE_XXX` environment variables

3. Settings in your JSON config ( `~/.fiftyone/annotation_config.json`)

4. The default config values


#### Editing your JSON config [¶](\#editing-your-json-config "Permalink to this headline")

You can permanently customize your annotation config by creating a
`~/.fiftyone/annotation_config.json` file on your machine. The JSON file may
contain any desired subset of config fields that you wish to customize.

For example, the following config JSON file customizes the URL of your CVAT
server without changing any other default config settings:

```python
{
    "backends": {
        "cvat": {
            "url": "http://localhost:8080"
        }
    }
}

```

When `fiftyone` is imported, any options from your JSON config are merged into
the default config, as per the order of precedence described above.

Note

You can customize the location from which your JSON config is read by
setting the `FIFTYONE_ANNOTATION_CONFIG_PATH` environment variable.

#### Setting environment variables [¶](\#setting-environment-variables "Permalink to this headline")

Annotation config settings may be customized on a per-session basis by setting
the `FIFTYONE_XXX` environment variable(s) for the desired config settings.

The `FIFTYONE_ANNOTATION_DEFAULT_BACKEND` environment variable allows you to
configure your default backend:

```python
export FIFTYONE_ANNOTATION_DEFAULT_BACKEND=labelbox

```

You can declare parameters for specific annotation backends by setting
environment variables of the form `FIFTYONE_<BACKEND>_<PARAMETER>`. Any
settings that you declare in this way will be passed as keyword arguments to
methods like
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate")
whenever the corresponding backend is in use. For example, you can configure
the URL, username, password, and email (if applicable) of your CVAT server as
follows:

```python
export FIFTYONE_CVAT_URL=http://localhost:8080
export FIFTYONE_CVAT_USERNAME=...
export FIFTYONE_CVAT_PASSWORD=...
export FIFTYONE_CVAT_EMAIL=...  # if applicable

```

The `FIFTYONE_ANNOTATION_BACKENDS` environment variable can be set to a
`list,of,backends` that you want to expose in your session, which may exclude
native backends and/or declare additional custom backends whose parameters are
defined via additional config modifications of any kind:

```python
export FIFTYONE_ANNOTATION_BACKENDS=custom,cvat,labelbox

```

When declaring new backends, you can include `*` to append new backend(s)
without omitting or explicitly enumerating the builtin backends. For example,
you can add a `custom` annotation backend as follows:

```python
export FIFTYONE_ANNOTATION_BACKENDS=*,custom
export FIFTYONE_CUSTOM_CONFIG_CLS=your.custom.AnnotationConfig

```

#### Modifying your config in code [¶](\#modifying-your-config-in-code "Permalink to this headline")

You can dynamically modify your annotation config at runtime by directly
editing the `fiftyone.annotation_config` object.

Any changes to your annotation config applied via this manner will immediately
take effect in all subsequent calls to `fiftyone.annotation_config` during your
current session.

```python
import fiftyone as fo

fo.annotation_config.default_backend = "<backend>"

```

## Requesting annotations [¶](\#requesting-annotations "Permalink to this headline")

Use the
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") method
to send the samples and optionally existing labels in a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or
[`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") to your annotation backend for processing.

The basic syntax is:

```python
anno_key = "..."
view.annotate(anno_key, ...)

```

The `anno_key` argument defines a unique identifier for the annotation run, and
you will provide it to methods like
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations"),
[`get_annotation_info()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations"),
[`load_annotation_results()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotation_results "fiftyone.core.collections.SampleCollection.load_annotation_results"),
[`rename_annotation_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.rename_annotation_run "fiftyone.core.collections.SampleCollection.rename_annotation_run"), and
[`delete_annotation_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.delete_annotation_run "fiftyone.core.collections.SampleCollection.delete_annotation_run")
to manage the run in the future.

Warning

FiftyOne assumes that all labels in an annotation run can fit in memory.

If you are annotating very large scale video datasets with dense frame
labels, you may violate this assumption. Instead, consider breaking the
work into multiple smaller annotation runs that each contain limited
subsets of the samples you wish to annotate.

You can use [`Dataset.stats()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.stats "fiftyone.core.dataset.Dataset.stats")
to get a sense for the total size of the labels in a dataset as a rule of
thumb to estimate the size of a candidate annotation run.

In addition,
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate")
provides various parameters that you can use to customize the annotation tasks
that you wish to be performed.

The following parameters are supported by all annotation backends:

- **backend** ( _None_): the annotation backend to use. The supported values
are `fiftyone.annotation_config.backends.keys()` and the default is
`fiftyone.annotation_config.default_backend`

- **media\_field** ( _“filepath”_): the sample field containing the path to the
source media to upload

- **launch\_editor** ( _False_): whether to launch the annotation backend’s
editor after uploading the samples


The following parameters allow you to configure the labeling schema to use for
your annotation tasks. See [this section](#annotation-label-schema) for
more details:

- **label\_schema** ( _None_): a dictionary defining the label schema to use.
If this argument is provided, it takes precedence over the remaining fields

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

  - `"scalar"`: scalar labels stored in [`IntField`](../api/fiftyone.core.fields.html#fiftyone.core.fields.IntField "fiftyone.core.fields.IntField"), [`FloatField`](../api/fiftyone.core.fields.html#fiftyone.core.fields.FloatField "fiftyone.core.fields.FloatField"),
    [`StringField`](../api/fiftyone.core.fields.html#fiftyone.core.fields.StringField "fiftyone.core.fields.StringField"), or [`BooleanField`](../api/fiftyone.core.fields.html#fiftyone.core.fields.BooleanField "fiftyone.core.fields.BooleanField") fields


All new label fields must have their type specified via this argument or in
`label_schema`

- **classes** ( _None_): a list of strings indicating the class options for
`label_field` or all fields in `label_schema` without classes specified.
All new label fields must have a class list provided via one of the
supported methods. For existing label fields, if classes are not provided
by this argument nor `label_schema`, the observed labels on your dataset
are used

- **attributes** ( _True_): specifies the label attributes of each label field
to include (other than their `label`, which is always included) in the
annotation export. Can be any of the following:


  - `True`: export all label attributes

  - `False`: don’t export any custom label attributes

  - a list of label attributes to export

  - a dict mapping attribute names to dicts specifying the `type`,
    `values`, and `default` for each attribute


If a `label_schema` is also provided, this parameter determines which
attributes are included for all fields that do not explicitly define their
per-field attributes (in addition to any per-class attributes)

- **mask\_targets** ( _None_): a dict mapping pixel values to semantic label
strings. Only applicable when annotating semantic segmentations

- **allow\_additions** ( _True_): whether to allow new labels to be added. Only
applicable when editing existing label fields

- **allow\_deletions** ( _True_): whether to allow labels to be deleted. Only
applicable when editing existing label fields

- **allow\_label\_edits** ( _True_): whether to allow the `label` attribute of
existing labels to be modified. Only applicable when editing existing
fields with `label` attributes

- **allow\_index\_edits** ( _True_): whether to allow the `index` attribute
of existing video tracks to be modified. Only applicable when editing
existing frame fields with `index` attributes

- **allow\_spatial\_edits** ( _True_): whether to allow edits to the spatial
properties (bounding boxes, vertices, keypoints, masks, etc) of labels.
Only applicable when editing existing spatial label fields


In addition, each annotation backend can typically be configured in a variety
of backend-specific ways. See [this section](#configuring-your-backend)
for more details.

Note

Specific annotation backends may not support all `label_type` options.

### Label schema [¶](\#label-schema "Permalink to this headline")

The `label_schema`, `label_field`, `label_type`, `classes`, `attributes`, and
`mask_targets` parameters to
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") allow
you to define the annotation schema that you wish to be used.

The label schema may define new label field(s) that you wish to populate, and
it may also include existing label field(s), in which case you can add, delete,
or edit the existing labels on your FiftyOne dataset.

The `label_schema` argument is the most flexible way to define how to construct
tasks in CVAT. In its most verbose form, it is a dictionary that defines the
label type, annotation type, possible classes, and possible attributes for each
label field:

```python
anno_key = "..."

label_schema = {
    "new_field": {
        "type": "classifications",
        "classes": ["class1", "class2"],
        "attributes": {
            "attr1": {
                "type": "select",
                "values": ["val1", "val2"],
                "default": "val1",
            },
            "attr2": {
                "type": "radio",
                "values": [True, False],
                "default": False,
            }
        },
    },
    "existing_field": {
        "classes": ["class3", "class4"],
        "attributes": {
            "attr3": {
                "type": "text",
            }
        }
    },
}

dataset.annotate(anno_key, label_schema=label_schema)

```

You can also define class-specific attributes by setting elements of the
`classes` list to dicts that specify groups of `classes` and their
corresponding `attributes`. For example, in the configuration below, `attr1`
only applies to `class1` and `class2` while `attr2` applies to all classes:

```python
anno_key = "..."

label_schema = {
    "new_field": {
        "type": "detections",
        "classes": [\
            {\
                "classes": ["class1", "class2"],\
                "attributes": {\
                    "attr1": {\
                        "type": "select",\
                        "values": ["val1", "val2"],\
                        "default": "val1",\
                    }\
                 }\
            },\
            "class3",\
            "class4",\
        ],
        "attributes": {
            "attr2": {
                "type": "radio",
                "values": [True, False],
                "default": False,
            }
        },
    },
}

dataset.annotate(anno_key, label_schema=label_schema)

```

Alternatively, if you are only editing or creating a single label field, you
can use the `label_field`, `label_type`, `classes`, `attributes`, and
`mask_targets` parameters to specify the components of the label schema
individually:

```python
anno_key = "..."

label_field = "new_field",
label_type = "classifications"
classes = ["class1", "class2"]

# These are optional
attributes = {
    "attr1": {
        "type": "select",
        "values": ["val1", "val2"],
        "default": "val1",
    },
    "attr2": {
        "type": "radio",
        "values": [True, False],
        "default": False,
    }
}

dataset.annotate(
    anno_key,
    label_field=label_field,
    label_type=label_type,
    classes=classes,
    attributes=attributes,
)

```

When you are annotating existing label fields, you can omit some of these
parameters from
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"), as
FiftyOne can infer the appropriate values to use:

- **label\_type**: if omitted, the [`Label`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") type of the field will be used to
infer the appropriate value for this parameter

- **classes**: if omitted for a non-semantic segmentation field, the observed
labels on your dataset will be used to construct a classes list


### Label attributes [¶](\#label-attributes "Permalink to this headline")

The `attributes` parameter allows you to configure whether
[custom attributes](using_datasets.md#using-labels) beyond the default `label` attribute
are included in the annotation tasks.

When adding new label fields for which you want to include attributes, you must
use the dictionary syntax demonstrated below to define the schema of each
attribute that you wish to label:

```python
anno_key = "..."

attributes = {
    "occluded": {
        "type": "radio",
        "values": [True, False],
        "default": False,
    },
    "gender": {
        "type": "select",
        "values": ["male", "female"],
    },
    "caption": {
        "type": "text",
    }
}

view.annotate(
    anno_key,
    label_field="new_field",
    label_type="detections",
    classes=["dog", "cat", "person"],
    attributes=attributes,
)

```

You can always omit this parameter if you do not require attributes beyond the
default `label`.

Each annotation backend may support different `type` values, as declared by the
[`supported_attr_types()`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackend.supported_attr_types "fiftyone.utils.annotations.AnnotationBackend.supported_attr_types")
method of its [`AnnotationBackend`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackend "fiftyone.utils.annotations.AnnotationBackend") class. For example, CVAT supports the
following choices for `type`:

- `text`: a free-form text box. In this case, `default` is optional and
`values` is unused

- `select`: a selection dropdown. In this case, `values` is required and
`default` is optional

- `radio`: a radio button list UI. In this case, `values` is required and
`default` is optional

- `checkbox`: a boolean checkbox UI. In this case, `default` is optional and
`values` is unused


When you are annotating existing label fields, the `attributes` parameter can
take additional values:

- `True` (default): export all custom attributes observed on the existing
labels, using their observed values to determine the appropriate UI type
and possible values, if applicable

- `False`: do not include any custom attributes in the export

- a list of custom attributes to include in the export

- a full dictionary syntax described above


Note that only scalar-valued label attributes are supported. Other attribute
types like lists, dictionaries, and arrays will be omitted.

### Restricting additions, deletions, and edits [¶](\#restricting-additions-deletions-and-edits "Permalink to this headline")

When you create annotation runs that involve editing existing label fields, you
can optionally specify that certain changes are not allowed by passing the
following flags to
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"):

- **allow\_additions** ( _True_): whether to allow new labels to be added

- **allow\_deletions** ( _True_): whether to allow labels to be deleted

- **allow\_label\_edits** ( _True_): whether to allow the `label` attribute to
be modified

- **allow\_index\_edits** ( _True_): whether to allow the `index` attribute of
video tracks to be modified

- **allow\_spatial\_edits** ( _True_): whether to allow edits to the spatial
properties (bounding boxes, vertices, keypoints, etc) of labels


If you are using the `label_schema` parameter to provide a full annotation
schema to
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"), you
can also directly include the above flags in the configuration dicts for any
existing label field(s) you wish.

For example, suppose you have an existing `ground_truth` field that contains
objects of various types and you would like to add new `sex` and `age`
attributes to all people in this field while also strictly enforcing that no
objects can be added, deleted, or have their labels or bounding boxes modified.
You can configure an annotation run for this as follows:

```python
anno_key = "..."

attributes = {
    "sex": {
        "type": "select",
        "values": ["male", "female"],
    },
    "age": {
        "type": "text",
    },
}

view.annotate(
    anno_key,
    label_field="ground_truth",
    classes=["person"],
    attributes=attributes,
    allow_additions=False,
    allow_deletions=False,
    allow_label_edits=False,
    allow_spatial_edits=False,
)

```

You can also include a `read_only=True` parameter when uploading existing
label attributes to specify that the attribute’s value should be uploaded to
the annotation backend for informational purposes, but any edits to the
attribute’s value should not be imported back into FiftyOne.

For example, if you have vehicles with their `make` attribute populated and you
want to populate a new `model` attribute based on this information without
allowing changes to the vehicle’s `make`, you can configure an annotation run
for this as follows:

```python
anno_key = "..."

attributes = {
    "make": {
        "type": "text",
        "read_only": True,
    },
    "model": {
        "type": "text",
    },
}

view.annotate(
    anno_key,
    label_field="ground_truth",
    classes=["vehicle"],
    attributes=attributes,
)

```

Note

Some annotation backends may not support restrictions to additions,
deletions, spatial edits, and read-only attributes in their editing
interface.

However, any restrictions that you specify via the above parameters will
still be enforced when you call
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
to merge the annotations back into FiftyOne.

### Labeling videos [¶](\#labeling-videos "Permalink to this headline")

When annotating spatiotemporal objects in videos, you have a few additional
options at your fingertips.

First, each object attribute specification can include a `mutable` property
that controls whether the attribute’s value can change between frames for each
object:

```python
anno_key = "..."

attributes = {
    "type": {
        "type": "select",
        "values": ["sedan", "suv", "truck"],
        "mutable": False,
    },
    "occluded": {
        "type": "radio",
        "values": [True, False],
        "default": False,
        "mutable": True,
    },
}

view.annotate(
    anno_key,
    label_field="frames.new_field",
    label_type="detections",
    classes=["vehicle"],
    attributes=attributes,
)

```

The meaning of the `mutable` attribute is defined as follows:

- `True` (default): the attribute is dynamic and can have a different value
for every frame in which the object track appears

- `False`: the attribute is static and is the same for every frame in which
the object track appears


In addition, if you are using an annotation backend
[like CVAT](../integrations/cvat.md#cvat-annotating-videos) that supports keyframes, then when
you [download annotation runs](#loading-annotations) that include track
annotations, the downloaded label corresponding to each keyframe of an object
track will have its `keyframe=True` attribute set to denote that it was a
keyframe.

Similarly, when you create an annotation run on a video dataset that involves
_editing_ existing video tracks, if at least one existing label has a
`keyframe=True` attribute set, then the available keyframe information will be
uploaded to the annotation backend.

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

Some annotation backends like CVAT cannot explicitly prevent annotators from
creating labels that don’t obey the run’s label schema. You can pass the
optional `unexpected` parameter to
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
to configure how to deal with any such unexpected labels that are found. The
supported values are:

- `"prompt"` ( **default**): present an interactive prompt to direct/discard
unexpected labels

- `"keep"`: automatically keep all unexpected labels in a field whose name
matches the the label type

- `"ignore"`: automatically ignore any unexpected labels

- `"return"`: return a dict containing all unexpected labels, if any


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

## Custom annotation backends [¶](\#custom-annotation-backends "Permalink to this headline")

If you would like to use an annotation tool that is not natively supported by
FiftyOne, you can follow the instructions below to implement an interface for
your tool and then configure your environment so that the
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") and
[`load_annotations()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_annotations "fiftyone.core.collections.SampleCollection.load_annotations")
methods will use your custom backend.

Annotation backends are defined by writing subclasses of the following
three classes with the appropriate abstract methods implemented:

- [`AnnotationBackend`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackend "fiftyone.utils.annotations.AnnotationBackend"): this class implements the logic required for your
annotation backend to declare the types of labeling tasks that it supports,
as well as the core
[`upload_annotations()`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackend.upload_annotations "fiftyone.utils.annotations.AnnotationBackend.upload_annotations")
and
[`download_annotations()`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackend.download_annotations "fiftyone.utils.annotations.AnnotationBackend.download_annotations")
methods, which handle uploading and downloading data and labels to your
annotation tool

- [`AnnotationBackendConfig`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackendConfig "fiftyone.utils.annotations.AnnotationBackendConfig"): this class defines the available parameters that
users can pass as keyword arguments to
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") to
customize the behavior of the annotation run

- [`AnnotationResults`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationResults "fiftyone.utils.annotations.AnnotationResults"):
this class stores any intermediate information necessary to track the
progress of an annotation run that has been created and is now waiting for
its results to be merged back into the FiftyOne dataset


Note

Refer to the
[fiftyone.utils.cvat](https://github.com/voxel51/fiftyone/blob/develop/fiftyone/utils/cvat.py)
module for an example of how the above subclasses are implemented for the
CVAT backend.

The recommended way to expose a custom backend is to add it to your
[annotation config](#annotation-config) at
`~/.fiftyone/annotation_config.json` as follows:

```python
{
    "default_backend": "<backend>",
    "backends": {
        "<backend>": {
            "config_cls": "your.custom.AnnotationConfig",
            # custom parameters here
        }
    }
}

```

In the above, `<backend>` defines the name of your custom backend, which you
can henceforward pass as the `backend` parameter to
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate"), and
the `config_cls` parameter specifies the fully-qualified name of the
[`AnnotationBackendConfig`](../api/fiftyone.utils.annotations.html#fiftyone.utils.annotations.AnnotationBackendConfig "fiftyone.utils.annotations.AnnotationBackendConfig") subclass for your annotation backend.

With the `default_backend` parameter set to your custom backend as shown above,
calling
[`annotate()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.annotate "fiftyone.core.collections.SampleCollection.annotate") will
automatically use your backend.

Alternatively, you can manually opt to use your custom backend on a per-run
basis by passing the `backend` parameter:

```python
view.annotate(..., backend="<backend>", ...)

```

