# Dataset Views [¶](\#dataset-views "Permalink to this headline")

FiftyOne provides methods that allow you to sort, slice, and search your
[`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") using any information that you have added to the [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset").
Performing these actions returns a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") into your [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") that will
show only the samples and labels therein that match your criteria.

Note

[`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") does not hold its contents in-memory. Views simply store the
rule(s) that are applied to extract the content of interest from the
underlying [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") when the view is iterated/aggregated on.

This means, for example, that the contents of a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") may change
as the underlying [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") is modified.

## Overview [¶](\#overview "Permalink to this headline")

A [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") is returned whenever any sorting, slicing, or searching
operation is performed on a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset").

You can explicitly create a view that contains an entire dataset via
[`Dataset.view()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.view "fiftyone.core.dataset.Dataset.view"):

```python
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

view = dataset.view()

print(view)

```

```python
Dataset:        quickstart
Media type:     image
Num samples:    200
Sample fields:
    id:               fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.ImageMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    ground_truth:     fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
    uniqueness:       fiftyone.core.fields.FloatField
    predictions:      fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
View stages:
    ---

```

You can access specific information about a view in the natural ways:

```python
len(view)
# 200

view.media_type
# "image"

```

Like datasets, you access the samples in a view by iterating over it:

```python
for sample in view:
    # Do something with `sample`

```

Or, you can access individual samples in a view by their ID or filepath:

```python
sample = view.take(1).first()

print(type(sample))
# fiftyone.core.sample.SampleView

same_sample = view[sample.id]
also_same_sample = view[sample.filepath]

view[other_sample_id]
# KeyError: sample non-existent or not in view

```

Note

Accessing samples in a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") returns [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") objects, not
[`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") objects. The two classes are largely interchangeable, but
[`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") provides some extra features. See
[filtering sample contents](#filtering-sample-contents) for more
details.

## Saving views [¶](\#saving-views "Permalink to this headline")

If you find yourself frequently using/recreating certain views, you can use
[`save_view()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.save_view "fiftyone.core.dataset.Dataset.save_view") to save them on
your dataset under a name of your choice:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")
dataset.persistent = True

# Create a view
cats_view = (
    dataset
    .select_fields("ground_truth")
    .filter_labels("ground_truth", F("label") == "cat")
    .sort_by(F("ground_truth.detections").length(), reverse=True)
)

# Save the view
dataset.save_view("cats-view", cats_view)

```

Then you can conveniently use
[`load_saved_view()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.load_saved_view "fiftyone.core.dataset.Dataset.load_saved_view")
to load the view in a future session:

```python
import fiftyone as fo

dataset = fo.load_dataset("quickstart")

# Retrieve a saved view
cats_view = dataset.load_saved_view("cats-view")
print(cats_view)

```

Note

Did you know? You can also save, load, and edit saved views directly
[from the App](app.md#app-saving-views)!

Saved views have certain editable metadata such as a description that you can
view via
[`get_saved_view_info()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.get_saved_view_info "fiftyone.core.dataset.Dataset.get_saved_view_info")
and update via
[`update_saved_view_info()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.update_saved_view_info "fiftyone.core.dataset.Dataset.update_saved_view_info"):

```python
# Get a saved view's editable info
print(dataset.get_saved_view_info("cats-view"))

# Update the saved view's name and add a description
info = dict(
    name="still-cats-view",
    description="a view that only contains cats",
)
dataset.update_saved_view_info("cats-view", info)

# Verify that the info has been updated
print(dataset.get_saved_view_info("still-cats-view"))

```

You can also use
[`list_saved_views()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.list_saved_views "fiftyone.core.dataset.Dataset.list_saved_views"),
[`has_saved_view()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.has_saved_view "fiftyone.core.dataset.Dataset.has_saved_view"),
and
[`delete_saved_view()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.delete_saved_view "fiftyone.core.dataset.Dataset.delete_saved_view")
to manage your saved views.

Note

Saved views only store the rule(s) used to extract content from the
underlying dataset, not the actual content itself. Saving views is cheap.
Don’t worry about storage space!

Keep in mind, though, that the contents of a saved view may change as the
underlying dataset is modified. For example, if a save view contains
samples with a certain tag, the view’s contents will change as you
add/remove this tag from samples.

## View stages [¶](\#view-stages "Permalink to this headline")

Dataset views encapsulate a pipeline of logical operations that determine which
samples appear in the view (and perhaps what subset of their contents).

Each view operation is captured by a [`ViewStage`](../api/fiftyone.core.stages.html#fiftyone.core.stages.ViewStage "fiftyone.core.stages.ViewStage"):

```python
# List available view operations on a dataset
print(dataset.list_view_stages())
# ['exclude', 'exclude_fields', 'exists', ..., 'skip', 'sort_by', 'take']

```

These operations are conveniently exposed as methods on [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") instances,
in which case they create an initial [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView"):

```python
# Random set of 100 samples from the dataset
random_view = dataset.take(100)

len(random_view)
# 100

```

They are also exposed on [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") instances, in which case they return
another [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") with the operation appended to its internal pipeline so
that multiple operations can be chained together:

```python
# Sort `random_view` by filepath
sorted_random_view = random_view.sort_by("filepath")

```

The sections below discuss some interesting view stages in more detail. You can
also refer to the [`fiftyone.core.stages`](../api/fiftyone.core.stages.html#module-fiftyone.core.stages "fiftyone.core.stages") module documentation for examples
of using each stage.

## Slicing [¶](\#slicing "Permalink to this headline")

You can extract a range of [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") instances from a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") using
[`skip()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.skip "fiftyone.core.collections.SampleCollection.skip") and
[`limit()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.limit "fiftyone.core.collections.SampleCollection.limit") or,
equivalently, by using array slicing:

```python
# Skip the first 2 samples and take the next 3
range_view1 = dataset.skip(2).limit(3)

# Equivalently, using array slicing
range_view2 = dataset[2:5]

```

Samples can be accessed from views in
[all the same ways](using_datasets.md#accessing-samples-in-a-dataset) as for datasets.
This includes using [`first()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.first "fiftyone.core.view.DatasetView.first") and
[`last()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.last "fiftyone.core.view.DatasetView.last") to retrieve the first and
last samples in a view, respectively, or accessing a sample directly from a
[`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") by its ID or filepath:

```python
view = dataset[10:100]

sample10 = view.first()
sample100 = view.last()

also_sample10 = view[sample10.id]
print(also_sample10.filepath == sample10.filepath)
# True

also_sample100 = view[sample100.filepath]
print(sample100.id == also_sample100.id)
# True

```

Note that, [unlike datasets](using_datasets.md#accessing-samples-in-a-dataset),
[`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") objects are not singletons, since there are an infinite number of
possible views into a particular [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample"):

```python
print(sample10 is also_sample10)
# False

```

Note

Accessing a sample by its integer index in a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") is not allowed.
The best practice is to lookup individual samples by ID or filepath, or use
array slicing to extract a range of samples, and iterate over samples in a
view.

```python
view[0]
# KeyError: Accessing samples by numeric index is not supported.
# Use sample IDs, filepaths, slices, boolean arrays, or a boolean ViewExpression instead

```

You can also use boolean array indexing to create a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") into a
dataset or view given an array-like of bools defining the samples you wish to
extract:

```python
import numpy as np

# A boolean array encoding the samples to extract
bool_array = np.array(dataset.values("uniqueness")) > 0.7

view = dataset[bool_array]
print(len(view))
# 17

```

The above syntax is equivalent to the following
[`select()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.select "fiftyone.core.collections.SampleCollection.select") statement:

```python
import itertools

ids = itertools.compress(dataset.values("id"), bool_array)
view = dataset.select(ids)
print(len(view))
# 17

```

Note that, whenever possible, the above operations are more elegantly
implemented using [match filters](#querying-samples):

```python
from fiftyone import ViewField as F

# ViewExpression defining the samples to match
expr = F("uniqueness") > 0.7

# Use a match() expression to define the view
view = dataset.match(expr)
print(len(view))
# 17

# Equivalent: using boolean expression indexing is allowed too
view = dataset[expr]
print(len(view))
# 17

```

## Sorting [¶](\#sorting "Permalink to this headline")

You can use
[`sort_by()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by "fiftyone.core.collections.SampleCollection.sort_by")
to sort the samples in a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") by a field of interest. The
samples in the returned [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") can be sorted in ascending or descending
order:

```python
view = dataset.sort_by("filepath")
view = dataset.sort_by("filepath", reverse=True)

```

You can also sort by [expressions](#querying-samples)!

```python
from fiftyone import ViewField as F

# Sort by number of detections in `Detections` field `ground_truth`
view = dataset.sort_by(F("ground_truth.detections").length(), reverse=True)

print(len(view.first().ground_truth.detections))  # 39
print(len(view.last().ground_truth.detections))  # 0

```

## Shuffling [¶](\#shuffling "Permalink to this headline")

The samples in a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") can be randomly shuffled using
[`shuffle()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.shuffle "fiftyone.core.collections.SampleCollection.shuffle"):

```python
# Randomly shuffle the order of the samples in the dataset
view1 = dataset.shuffle()

```

An optional `seed` can be provided to make the shuffle deterministic:

```python
# Randomly shuffle the samples in the dataset with a fixed seed

view2 = dataset.shuffle(seed=51)
print(view2.first().id)
# 5f31bbfcd0d78c13abe159b1

also_view2 = dataset.shuffle(seed=51)
print(also_view2.first().id)
# 5f31bbfcd0d78c13abe159b1

```

## Random sampling [¶](\#random-sampling "Permalink to this headline")

You can extract a random subset of the samples in a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView")
using [`take()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.take "fiftyone.core.collections.SampleCollection.take"):

```python
# Take 5 random samples from the dataset
view1 = dataset.take(5)

```

An optional `seed` can be provided to make the sampling deterministic:

```python
# Take 5 random samples from the dataset with a fixed seed

view2 = dataset.take(5, seed=51)
print(view2.first().id)
# 5f31bbfcd0d78c13abe159b1

also_view2 = dataset.take(5, seed=51)
print(also_view2.first().id)
# 5f31bbfcd0d78c13abe159b1

```

## Filtering [¶](\#filtering "Permalink to this headline")

The real power of [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") is the ability to write your own search queries
based on your data.

### Querying samples [¶](\#querying-samples "Permalink to this headline")

You can query for a subset of the samples in a dataset via the
[`match()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match "fiftyone.core.collections.SampleCollection.match") method. The
syntax is:

```python
match_view = dataset.match(expression)

```

where `expression` defines the matching expression to use to decide whether to
include a sample in the view.

FiftyOne provides powerful [`ViewField`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewField "fiftyone.core.expressions.ViewField") and [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") classes that allow
you to use native Python operators to define your match expression. Simply wrap
the target field of your sample in a [`ViewField`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewField "fiftyone.core.expressions.ViewField") and then apply comparison,
logic, arithmetic or array operations to it to create a [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression"). You
can use [dot notation](https://docs.mongodb.com/manual/core/document/#dot-notation)
to refer to fields or subfields of the embedded documents in your samples.
Any resulting [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") that returns a boolean is a valid expression!

The code below shows a few examples. See the API reference for [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression")
for a full list of supported operations.

```python
from fiftyone import ViewField as F

# Populate metadata on all samples
dataset.compute_metadata()

# Samples whose image is less than 48 KB
small_images_view = dataset.match(F("metadata.size_bytes") < 48 * 1024)

# Samples that contain at least one prediction with confidence above 0.99
# or whose label ifs "cat" or "dog"
match = (F("confidence") > 0.99) | (F("label").is_in(("cat", "dog")))
matching_view = dataset.match(
    F("predictions.detections").filter(match).length() > 0
)

```

### Common filters [¶](\#common-filters "Permalink to this headline")

Convenience functions for common queries are also available.

Use the
[`match_tags()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_tags "fiftyone.core.collections.SampleCollection.match_tags")
method to match samples that have the specified tag(s) in their `tags` field:

```python
# The validation split of the dataset
val_view = dataset.match_tags("validation")

# Union of the validation and test splits
val_test_view = dataset.match_tags(("validation", "test"))

```

Use [`exists()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.exists "fiftyone.core.collections.SampleCollection.exists") to
only include samples for which a given [`Field`](../api/fiftyone.core.fields.html#fiftyone.core.fields.Field "fiftyone.core.fields.Field") exists and is not `None`:

```python
# The subset of samples where predictions have been computed
predictions_view = dataset.exists("predictions")

```

Use [`select()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.select "fiftyone.core.collections.SampleCollection.select") and
[`exclude()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.exclude "fiftyone.core.collections.SampleCollection.exclude") to
restrict attention to or exclude samples from a view by their IDs:

```python
# Get the IDs of two random samples
sample_ids = [\
    dataset.take(1).first().id,\
    dataset.take(1).first().id,\
]

# Include only samples with the given IDs in the view
selected_view = dataset.select(sample_ids)

# Exclude samples with the given IDs from the view
excluded_view = dataset.exclude(sample_ids)

```

### Filtering sample contents [¶](\#filtering-sample-contents "Permalink to this headline")

Dataset views can also be used to _filter the contents_ of samples in the view.
That’s why [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") instances return [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") objects rather than
[`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") objects.

[`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") instances represent the content of your samples in all of the
usual ways, with some important caveats:

- If you modify the contents of a [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") and then
[`save()`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample.save "fiftyone.core.sample.Sample.save") it, any changes that
you made to the contents of the [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") will be reflected in the
database.

- Sample views can exclude fields and filter elements of a field (e.g., omit
certain detections from an array of detections in the sample). This means
that [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") instances need not contain all of the information in a
sample.

- Sample views are not singletons and thus you must explicitly
[`reload()`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample.reload "fiftyone.core.sample.Sample.reload") them in order to
refresh their contents if the underlying sample has been modified elsewhere.
However, extracting a [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") from a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") always returns the
updated version of the sample’s contents.


You can use the
[`select_fields()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.select_fields "fiftyone.core.collections.SampleCollection.select_fields")
and
[`exclude_fields()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.exclude_fields "fiftyone.core.collections.SampleCollection.exclude_fields")
stages to select or exclude fields from the returned [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView"):

```python
for sample in dataset.select_fields("ground_truth"):
    print(sample.id)            # OKAY: `id` is always available
    print(sample.ground_truth)  # OKAY: `ground_truth` was selected
    print(sample.predictions)   # AttributeError: `predictions` was not selected

for sample in dataset.exclude_fields("predictions"):
    print(sample.id)            # OKAY: `id` is always available
    print(sample.ground_truth)  # OKAY: `ground_truth` was not excluded
    print(sample.predictions)   # AttributeError: `predictions` was excluded

```

The
[`filter_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_labels "fiftyone.core.collections.SampleCollection.filter_labels")
stage is a powerful stage that allows you to filter the contents of
[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), [`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications"), [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"), and [`Keypoints`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoints "fiftyone.core.labels.Keypoints") fields,
respectively.

Here are some self-contained examples for each task:

You can also use the
[`filter_field()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_field "fiftyone.core.collections.SampleCollection.filter_field")
stage to filter the contents of arbitrarily-typed fields:

```python
# Remove tags from samples that don't include the "validation" tag
clean_tags_view = dataset.filter_field("tags", F().contains("validation"))

```

Note

When you create a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") that contains filtered detections or
classifications, the other labels are not removed from the source dataset,
even if you [`save()`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample.save "fiftyone.core.sample.Sample.save") a
[`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") after modifying the filtered detections. This is because each
label is updated individually, and other labels in the field are left
unchanged.

```python
view = dataset.filter_labels("predictions", ...)

for sample in view:
    predictions = sample.predictions

    # Modify the detections in the view
    for detection in predictions.detections:
        detection["new_field"] = True

    # Other detections in the `predictions` field of the samples that
    # did not appear in the `view` are not deleted or modified
    sample.save()

```

If you _do want to delete data_ from your samples, assign a new value to
the field:

```python
view = dataset.filter_labels("predictions", ...)

for sample in view:
    sample.predictions = fo.Detections(...)

    # Existing detections in the `predictions` field of the samples
    # are deleted
    sample.save()

```

## Grouping [¶](\#grouping "Permalink to this headline")

You can use
[`group_by()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.group_by "fiftyone.core.collections.SampleCollection.group_by") to
dynamically group the samples in a collection by a specified field:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("cifar10", split="test")

# Take 100 samples and group by ground truth label
view = dataset.take(100, seed=51).group_by("ground_truth.label")

print(view.media_type)  # group
print(len(view))  # 10

```

Note

Views generated by
[`group_by()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.group_by "fiftyone.core.collections.SampleCollection.group_by")
have media type `group`.

By default, the samples in each group are unordered, but you can provide the
optional `order_by` and `reverse` arguments to
[`group_by()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.group_by "fiftyone.core.collections.SampleCollection.group_by") to
specify an ordering for the samples in each group:

```python
# Create an image dataset that contains one sample per frame of the
# `quickstart-video` dataset
dataset2 = (
    foz.load_zoo_dataset("quickstart-video")
    .to_frames(sample_frames=True)
    .clone()
)

print(len(dataset2))  # 1279

# Group by video ID and order each group by frame number
view2 = dataset2.group_by("sample_id", order_by="frame_number")

print(len(view2))  # 10
print(view2.values("frame_number"))
# [1, 1, 1, ..., 1]

sample_id = dataset2.take(1).first().sample_id
video = view2.get_dynamic_group(sample_id)

print(video.values("frame_number"))
# [1, 2, 3, ..., 120]

```

You can also group by an arbitrary [expressions](#querying-samples):

```python
dataset3 = foz.load_zoo_dataset("quickstart")

# Group samples by the number of ground truth objects they contain
expr = F("ground_truth.detections").length()
view3 = dataset3.group_by(expr)

print(len(view3))  # 26
print(len(dataset3.distinct(expr)))  # 26

```

When you iterate over a dynamic grouped view, you get one example from each
group. Like any other view, you can chain additional view stages to further
refine the view’s contents:

```python
# Sort the groups by label
sorted_view = view.sort_by("ground_truth.label")

for sample in sorted_view:
    print(sample.ground_truth.label)

```

```python
airplane
automobile
bird
cat
deer
dog
frog
horse
ship
truck

```

In particular, you can use
[`flatten()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.flatten "fiftyone.core.collections.SampleCollection.flatten") to
unravel the samples in a dynamic grouped view back into a flat view:

```python
# Unwind the sorted groups back into a flat collection
flat_sorted_view = sorted_view.flatten()

print(len(flat_sorted_view))  # 1000
print(flat_sorted_view.values("ground_truth.label"))
# ['airplane', 'airplane', 'airplane', ..., 'truck']

```

Note

Did you know? When you load dynamic group views
[in the App](app.md#app-dynamic-groups), the grid view shows the first
example from each group, and you can click on any sample to open the modal
and view all samples in the group.

You can use
[`get_dynamic_group()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.get_dynamic_group "fiftyone.core.view.DatasetView.get_dynamic_group")
to retrieve a view containing the samples with a specific group value of
interest:

```python
group = view.get_dynamic_group("horse")
print(len(group))  # 11

```

You can also use
[`iter_dynamic_groups()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.iter_dynamic_groups "fiftyone.core.view.DatasetView.iter_dynamic_groups")
to iterate over all groups in a dynamic group view:

```python
for group in sorted_view.iter_dynamic_groups():
    print("%s: %d" % (group.first().ground_truth.label, len(group)))

```

```python
airplane: 11
automobile: 10
bird: 8
cat: 12
deer: 6
dog: 7
frog: 10
horse: 11
ship: 12
truck: 13

```

## Concatenating views [¶](\#concatenating-views "Permalink to this headline")

You can use
[`concat()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.concat "fiftyone.core.collections.SampleCollection.concat") to
concatenate views into the same dataset:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")

view1 = dataset.match(F("uniqueness") < 0.2)
view2 = dataset.match(F("uniqueness") > 0.7)

view = view1.concat(view2)

print(len(view) == len(view1) + len(view2))  # True

```

or you can use the equivalent `+` syntax sugar:

```python
view = view1 + view2

print(len(view) == len(view1) + len(view2))  # True

```

Concatenating _generated views_ such as [patches](#object-patches-views)
and [frames](#frame-views) is also allowed:

```python
gt_patches = dataset.to_patches("ground_truth")

patches1 = gt_patches[:10]
patches2 = gt_patches[-10:]

patches = patches1 + patches2

print(len(patches) == len(patches1) + len(patches2))  # True

```

as long as each view is derived from the same root generated view:

```python
patches1 = dataset[:10].to_patches("ground_truth")
patches2 = dataset[-10:].to_patches("ground_truth")

patches = patches1 + patches2  # ERROR: not allowed

```

If you concatenate views that use
[`select_fields()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.select_fields "fiftyone.core.collections.SampleCollection.select_fields")
or
[`exclude_fields()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.exclude_fields "fiftyone.core.collections.SampleCollection.exclude_fields")
to manipulate the schema of individual views, the concatenated view will
respect the schema of the _first view_ in the chain:

```python
view1 = dataset[:10].select_fields()
view2 = dataset[-10:]

view = view1 + view2

# Fields are omitted from `view2` to match schema of `view1`
print(view.last())

```

```python
view1 = dataset[:10]
view2 = dataset[-10:].select_fields()

view = view1 + view2

# Missing fields from `view2` appear as `None` to match schema of `view1`
print(view.last())

```

Note that [`concat()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.concat "fiftyone.core.collections.SampleCollection.concat")
will not prevent you from creating concatenated views that contain multiple
(possibly filtered) versions of the same [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample"), which results in views that
contains duplicate sample IDs:

```python
sample_id = dataset.first().id
view = (dataset + dataset).shuffle()

selected_view = view.select(sample_id)
print(len(selected_view))  # two samples have the same ID

```

Warning

The [FiftyOne App](app.md#fiftyone-app) is not designed to display views
with duplicate sample IDs.

## Date-based views [¶](\#date-based-views "Permalink to this headline")

If your dataset contains [date fields](using_datasets.md#dates-and-datetimes), you can
construct dataset views that query/filter based on this information by simply
writing the appropriate [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression"), using `date`, `datetime` and
`timedelta` objects to define the required logic.

For example, you can use the
[`match()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match "fiftyone.core.collections.SampleCollection.match") stage to
filter a dataset by date as follows:

```python
from datetime import datetime, timedelta

import fiftyone as fo
from fiftyone import ViewField as F

dataset = fo.Dataset()
dataset.add_samples(
    [\
        fo.Sample(\
            filepath="image1.png",\
            capture_date=datetime(2021, 8, 24, 1, 0, 0),\
        ),\
        fo.Sample(\
            filepath="image2.png",\
            capture_date=datetime(2021, 8, 24, 2, 0, 0),\
        ),\
        fo.Sample(\
            filepath="image3.png",\
            capture_date=datetime(2021, 8, 24, 3, 0, 0),\
        ),\
    ]
)

query_date = datetime(2021, 8, 24, 2, 1, 0)
query_delta = timedelta(minutes=30)

# Samples with capture date after 2021-08-24 02:01:00
view = dataset.match(F("capture_date") > query_date)
print(view)

# Samples with capture date within 30 minutes of 2021-08-24 02:01:00
view = dataset.match(abs(F("capture_date") - query_date) < query_delta)
print(view)

```

Note

As the example above demonstrates, [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") instances may contain
`date`, `datetime` and `timedelta` objects. Internally, subtracting two
dates returns the number of milliseconds between them. Using `timedelta`
allows these units to be abstracted away from the user.

## Object patches [¶](\#object-patches "Permalink to this headline")

If your dataset contains label list fields like [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") or [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines"),
then you can use
[`to_patches()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_patches "fiftyone.core.collections.SampleCollection.to_patches") to
create views that contain one sample per object patch in a specified label
field of your dataset.

For example, you can extract patches for all ground truth objects in a
detection dataset:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")

session = fo.launch_app(dataset)

# Convert to ground truth patches
gt_patches = dataset.to_patches("ground_truth")
print(gt_patches)

# View patches in the App
session.view = gt_patches

```

```python
Dataset:     quickstart
Media type:  image
Num patches: 1232
Patch fields:
    id:               fiftyone.core.fields.ObjectIdField
    sample_id:        fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.ImageMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    ground_truth:     fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detection)
View stages:
    1. ToPatches(field='ground_truth', config=None)

```

Note

You can pass the optional `other_fields` parameter to
[`to_patches()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_patches "fiftyone.core.collections.SampleCollection.to_patches")
to specify additional read-only sample-level fields that each patch should
include from their parent samples.

Or, you could [chain view stages](#chaining-views) to create a view that
contains patches for a filtered set of predictions:

```python
# Now extract patches for confident person predictions
person_patches = (
    dataset
    .filter_labels(
        "predictions",
        (F("label") == "person") & (F("confidence") > 0.9)
    )
    .to_patches("predictions")
)
print(person_patches)

# View patches in the App
session.view = person_patches

```

Note

Did you know? You can convert to object patches view directly
[from the App](app.md#app-object-patches)!

Object patches views are just like any other [dataset view](#using-views)
in the sense that:

- You can append view stages via the [App view bar](app.md#app-create-view) or
[views API](#using-views)

- Any modifications to label tags that you make via the App’s
[tagging menu](app.md#app-tagging) or via API methods like
[`tag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.tag_labels "fiftyone.core.collections.SampleCollection.tag_labels")
and [`untag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.untag_labels "fiftyone.core.collections.SampleCollection.untag_labels")
will be reflected on the source dataset

- Any modifications to the patch labels that you make by iterating over the
contents of the view or calling
[`set_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_values "fiftyone.core.collections.SampleCollection.set_values")
or
[`set_label_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_label_values "fiftyone.core.collections.SampleCollection.set_label_values")
will be reflected on the source dataset

- Calling [`save()`](../api/fiftyone.core.patches.html#fiftyone.core.patches.PatchesView.save "fiftyone.core.patches.PatchesView.save"),
[`keep()`](../api/fiftyone.core.patches.html#fiftyone.core.patches.PatchesView.keep "fiftyone.core.patches.PatchesView.keep"), or
[`keep_fields()`](../api/fiftyone.core.patches.html#fiftyone.core.patches.PatchesView.keep_fields "fiftyone.core.patches.PatchesView.keep_fields") on a
patches view (typically one that contains additional view stages that
filter or modify its contents) will sync any edits or deletions to the
patch labels with the source dataset


However, because object patches views only contain a subset of the contents of
a [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") from the source dataset, there are some differences compared to
non-patch views:

- Tagging or untagging patches (as opposed to their labels) will not affect
the tags of the underlying [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample")

- Any edits that you make to sample-level fields of object patches views
other than the field that defines the patches themselves will not be
reflected on the source dataset


Note

Did you know? You can [export object patches](export_datasets.md#export-label-coercion)
as classification datasets!

## Evaluation patches [¶](\#evaluation-patches "Permalink to this headline")

If you have [run evaluation](evaluation.md#evaluating-detections) on predictions from
an object detection model, then you can use
[`to_evaluation_patches()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_evaluation_patches "fiftyone.core.collections.SampleCollection.to_evaluation_patches")
to transform the dataset (or a view into it) into a new view that contains one
sample for each true positive, false positive, and false negative example.

True positive examples will result in samples with both their ground truth and
predicted fields populated, while false positive/negative examples will only
have one of their corresponding predicted/ground truth fields populated,
respectively.

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# Evaluate `predictions` w.r.t. labels in `ground_truth` field
dataset.evaluate_detections(
    "predictions", gt_field="ground_truth", eval_key="eval"
)

session = fo.launch_app(dataset)

# Convert to evaluation patches
eval_patches = dataset.to_evaluation_patches("eval")
print(eval_patches)

print(eval_patches.count_values("type"))
# {'fn': 246, 'fp': 4131, 'tp': 986}

# View patches in the App
session.view = eval_patches

```

```python
Dataset:     quickstart
Media type:  image
Num patches: 5363
Patch fields:
    id:               fiftyone.core.fields.ObjectIdField
    sample_id:        fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.ImageMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    predictions:      fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
    ground_truth:     fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
    type:             fiftyone.core.fields.StringField
    iou:              fiftyone.core.fields.FloatField
    crowd:            fiftyone.core.fields.BooleanField
View stages:
    1. ToEvaluationPatches(eval_key='eval', config=None)

```

Note

You can pass the optional `other_fields` parameter to
[`to_patches()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_patches "fiftyone.core.collections.SampleCollection.to_patches")
to specify additional read-only sample-level fields that each patch should
include from their parent samples.

Refer to the [evaluation guide](evaluation.md#evaluating-detections) guide for more
information about running evaluations and using evaluation patches views to
analyze object detection models.

Note

Did you know? You can convert to evaluation patches view directly
[from the App](app.md#app-evaluation-patches)!

Evaluation patches views are just like any other
[dataset view](#using-views) in the sense that:

- You can append view stages via the [App view bar](app.md#app-create-view) or
[views API](#using-views)

- Any modifications to ground truth or predicted label tags that you make via
the App’s [tagging menu](app.md#app-tagging) or via API methods like
[`tag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.tag_labels "fiftyone.core.collections.SampleCollection.tag_labels")
and [`untag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.untag_labels "fiftyone.core.collections.SampleCollection.untag_labels")
will be reflected on the source dataset

- Any modifications to the predicted or ground truth [`Label`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") elements in the
patches view that you make by iterating over the contents of the view or
calling
[`set_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_values "fiftyone.core.collections.SampleCollection.set_values")
or
[`set_label_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_label_values "fiftyone.core.collections.SampleCollection.set_label_values")
will be reflected on the source dataset

- Calling [`save()`](../api/fiftyone.core.patches.html#fiftyone.core.patches.EvaluationPatchesView.save "fiftyone.core.patches.EvaluationPatchesView.save"),
[`keep()`](../api/fiftyone.core.patches.html#fiftyone.core.patches.EvaluationPatchesView.keep "fiftyone.core.patches.EvaluationPatchesView.keep"), or
[`keep_fields()`](../api/fiftyone.core.patches.html#fiftyone.core.patches.EvaluationPatchesView.keep_fields "fiftyone.core.patches.EvaluationPatchesView.keep_fields")
on an evaluation patches view (typically one that contains additional view
stages that filter or modify its contents) will sync any predicted or
ground truth [`Label`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") edits or deletions with the source dataset


However, because evaluation patches views only contain a subset of the contents
of a [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") from the source dataset, there are some differences compared to
non-patch views:

- Tagging or untagging patches themselves (as opposed to their labels) will
not affect the tags of the underlying [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample")

- Any edits that you make to sample-level fields of evaluation patches views
other than the ground truth/predicted label fields will not be reflected
on the source dataset


## Video views [¶](\#video-views "Permalink to this headline")

Most view stages naturally support video datasets. For example, stages that
refer to fields can be applied to the frame-level fields of video samples by
prepending `"frames."` to the relevant parameters:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart-video")

# Create a view that only contains vehicles
view = dataset.filter_labels("frames.detections", F("label") == "vehicle")

# Compare the number of objects in the view and the source dataset
print(dataset.count("frames.detections.detections"))  # 11345
print(view.count("frames.detections.detections"))  # 7511

```

In addition, FiftyOne provides a variety of dedicated view stages for
performing manipulations that are unique to video data.

### Clip views [¶](\#clip-views "Permalink to this headline")

You can use
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips") to
create views into your video datasets that contain one sample per clip defined
by a specific field or expression in a video collection.

For example, if you have [temporal detection](using_datasets.md#temporal-detection) labels
on your dataset, then you can create a clips view that contains one sample per
temporal segment by simply passing the name of the temporal detection field to
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips"):

```python
import fiftyone as fo

dataset = fo.Dataset()

sample1 = fo.Sample(
    filepath="video1.mp4",
    events=fo.TemporalDetections(
        detections=[\
            fo.TemporalDetection(label="meeting", support=[1, 3]),\
            fo.TemporalDetection(label="party", support=[2, 4]),\
        ]
    ),
)

sample2 = fo.Sample(
    filepath="video2.mp4",
    metadata=fo.VideoMetadata(total_frame_count=5),
    events=fo.TemporalDetections(
        detections=[\
            fo.TemporalDetection(label="party", support=[1, 3]),\
            fo.TemporalDetection(label="meeting", support=[3, 5]),\
        ]
    ),
)

dataset.add_samples([sample1, sample2])

# Create a clips view with one clip per event
view = dataset.to_clips("events")
print(view)

# Verify that one sample per clip was created
print(dataset.count("events.detections"))  # 4
print(len(view))  # 4

```

```python
Dataset:    2021.09.03.09.44.57
Media type: video
Num clips:  4
Clip fields:
    id:               fiftyone.core.fields.ObjectIdField
    sample_id:        fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    support:          fiftyone.core.fields.FrameSupportField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.VideoMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    events:           fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Classification)
Frame fields:
    id:               fiftyone.core.fields.ObjectIdField
    frame_number:     fiftyone.core.fields.FrameNumberField
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
View stages:
    1. ToClips(field_or_expr='events', config=None)

```

All clips views contain a top-level `support` field that contains the
`[first, last]` frame range of the clip within `filepath`, which points to the
source video.

Note that the `events` field, which had type [`TemporalDetections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.TemporalDetections "fiftyone.core.labels.TemporalDetections") in the
source dataset, now has type [`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification") in the clips view, since each
classification has a one-to-one relationship with its clip.

Note

You can pass the optional `other_fields` parameter to
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips") to
specify additional read-only sample-level fields that each clip should
include from their parent samples.

Note

If you edit the `support` or [`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification") of a sample in a clips view
created from temporal detections, the changes will be applied to the
corresponding [`TemporalDetection`](../api/fiftyone.core.labels.html#fiftyone.core.labels.TemporalDetection "fiftyone.core.labels.TemporalDetection") in the source dataset.

Continuing from the example above, if you would like to see clips only for
specific temporal detection labels, you can achieve this by first
[filtering the labels](#filtering-sample-contents):

```python
from fiftyone import ViewField as F

# Create a clips view with one clip per meeting
view = (
    dataset
    .filter_labels("events", F("label") == "meeting")
    .to_clips("events")
)

print(view.values("events.label"))
# ['meeting', 'meeting']

```

Clips views can also be created based on frame-level labels, which provides a
powerful query language that you can use to find segments of a video dataset
that contain specific frame content of interest.

In the simplest case, you can provide the name of a frame-level list field
(e.g., [`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications") or [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections")) to
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips"), which
will create one clip per contiguous range of frames that contain at least one
label in the specified field:

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart-video")

# Create a view that contains one clip per contiguous range of frames that
# contains at least one detection
view = dataset.to_clips("frames.detections")
print(view)

```

The above view turns out to not be very interesting, since every frame in the
`quickstart-video` dataset contains at least one object. So, instead, lets
first [filter the objects](#filtering-sample-contents) so that we can
construct a clips view that contains one clip per contiguous range of frames
that contains at least one person:

```python
from fiftyone import ViewField as F

# Create a view that contains one clip per contiguous range of frames that
# contains at least one person
view = (
    dataset
    .filter_labels("frames.detections", F("label") == "person")
    .to_clips("frames.detections")
)
print(view)

```

```python
Dataset:    quickstart-video
Media type: video
Num clips:  8
Clip fields:
    id:               fiftyone.core.fields.ObjectIdField
    sample_id:        fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    support:          fiftyone.core.fields.FrameSupportField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.VideoMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
Frame fields:
    id:               fiftyone.core.fields.ObjectIdField
    frame_number:     fiftyone.core.fields.FrameNumberField
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    detections:       fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
View stages:
    1. FilterLabels(field='frames.detections', filter={'$eq': ['$$this.label', 'person']}, only_matches=True)
    2. ToClips(field_or_expr='frames.detections', config=None)

```

When you iterate over the frames of a sample in a clip view, you will only get
the frames within the `[first, last]` support of each clip:

```python
sample = view.last()

print(sample.support)
# [116, 120]

frame_numbers = []
for frame_number, frame in sample.frames.items():
    frame_numbers.append(frame_number)

print(frame_numbers)
# [116, 117, 118, 119, 120]

```

Note

Clips views created via
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips")
always contain all frame-level labels from the underlying dataset for
their respective frame supports, even if frame-level filtering was applied
in previous view stages. In other words, filtering prior to the
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips")
stage only affects the frame supports.

You can, however, apply frame-level filtering to clips by appending
filtering operations after the
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips")
stage in your view, just like any other view.

More generally, you can provide an arbitrary [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") to
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips") that
defines a boolean expression to apply to each frame. In this case, the clips
view will contain one clip per contiguous range of frames for which the
expression evaluates to true:

```python
# Create a view that contains one clip per contiguous range of frames that
# contains at least 10 vehicles
view = (
    dataset
    .filter_labels("frames.detections", F("label") == "vehicle")
    .to_clips(F("detections.detections").length() >= 10)
)
print(view)

```

See [this section](#querying-frames) for more information about
constructing frame expressions.

Note

You can pass optional `tol` and `min_len` parameters to
[`to_clips()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_clips "fiftyone.core.collections.SampleCollection.to_clips") to
configure a missing frame tolerance and minimum length for clips generated
from frame-level fields or expressions.

Clip views are just like any other [dataset view](#using-views) in the
sense that:

- You can append view stages via the [App view bar](app.md#app-create-view) or
[views API](#using-views)

- Any modifications to label tags that you make via the App’s
[tagging menu](app.md#app-tagging) or via API methods like
[`tag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.tag_labels "fiftyone.core.collections.SampleCollection.tag_labels")
and [`untag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.untag_labels "fiftyone.core.collections.SampleCollection.untag_labels")
will be reflected on the source dataset

- Any modifications to the frame-level labels in a clips view that you make
by iterating over the contents of the view or calling
[`set_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_values "fiftyone.core.collections.SampleCollection.set_values")
or
[`set_label_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_label_values "fiftyone.core.collections.SampleCollection.set_label_values")
will be reflected on the source dataset

- Calling [`save()`](../api/fiftyone.core.clips.html#fiftyone.core.clips.ClipsView.save "fiftyone.core.clips.ClipsView.save"),
[`keep()`](../api/fiftyone.core.clips.html#fiftyone.core.clips.ClipsView.keep "fiftyone.core.clips.ClipsView.keep"), or
[`keep_fields()`](../api/fiftyone.core.clips.html#fiftyone.core.clips.ClipsView.keep_fields "fiftyone.core.clips.ClipsView.keep_fields") on a
clips view (typically one that contains additional view stages that filter
or modify its contents) will sync any frame-level edits or deletions with
the source dataset


However, because clip views represent only a subset of a [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") from the
source dataset, there are some differences compared to non-clip views:

- Tagging or untagging clips (as opposed to their labels) will not affect
the tags of the underlying [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample")

- Any edits that you make to sample-level fields of clip views will not be
reflected on the source dataset (except for edits to the `support` and
[`Classification`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classification "fiftyone.core.labels.Classification") field populated when generating clip views based on
[`TemporalDetection`](../api/fiftyone.core.labels.html#fiftyone.core.labels.TemporalDetection "fiftyone.core.labels.TemporalDetection") labels, as described above)


### Trajectory views [¶](\#trajectory-views "Permalink to this headline")

You can use
[`to_trajectories()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_trajectories "fiftyone.core.collections.SampleCollection.to_trajectories")
to create views into your video datasets that contain one sample per each
unique object trajectory defined by their `(label, index)` in a frame-level
[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") or [`Polylines`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Polylines "fiftyone.core.labels.Polylines") field.

Trajectory views are a special case of [clip views](#clip-views) where
each clip has been filtered to contain only the identifying object, rather than
than all objects with the trajectory’s frame support.

For example, if you have frame-level
[object detections](using_datasets.md#object-detection) with their `index` attributes
populated, then you can create a trajectories view that contains one clip for
each object of a specific type using
[`filter_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_labels "fiftyone.core.collections.SampleCollection.filter_labels")
and
[`to_trajectories()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_trajectories "fiftyone.core.collections.SampleCollection.to_trajectories")
as shown below:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart-video")

# Create a trajectories view for the vehicles in the dataset
trajectories = (
    dataset
    .filter_labels("frames.detections", F("label") == "vehicle")
    .to_trajectories("frames.detections")
)
print(trajectories)

session = fo.launch_app(view=trajectories)

```

```python
Dataset:    quickstart-video
Media type: video
Num clips:  109
Clip fields:
    id:               fiftyone.core.fields.ObjectIdField
    sample_id:        fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    support:          fiftyone.core.fields.FrameSupportField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.VideoMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    detections:       fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.odm.embedded_document.DynamicEmbeddedDocument)
Frame fields:
    id:               fiftyone.core.fields.ObjectIdField
    frame_number:     fiftyone.core.fields.FrameNumberField
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    detections:       fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
View stages:
    1. FilterLabels(field='frames.detections', filter={'$eq': ['$$this.label', 'vehicle']}, only_matches=True, trajectories=False)
    2. ToTrajectories(field='frames.detections', config=None)

```

Warning

Trajectory views can contain significantly more frames than their source
collection, since the number of frames is now `O(# boxes)` rather than
`O(# video frames)`.

### Frame views [¶](\#frame-views "Permalink to this headline")

You can use
[`to_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_frames "fiftyone.core.collections.SampleCollection.to_frames")
to create image views into your video datasets that contain one sample per
frame in the dataset.

Note

Did you know? Using
[`to_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_frames "fiftyone.core.collections.SampleCollection.to_frames")
enables you to execute workflows such as
[model evaluation](evaluation.md#evaluating-models) and
[Brain methods](brain.md#fiftyone-brain) that only support image collections
to the frames of your video datasets!

In the simplest case, you can create a view that contains a sample for every
frame of the videos in a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") or [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView"):

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart-video")

session = fo.launch_app(dataset)

# Create a frames view for the entire dataset
frames = dataset.to_frames(sample_frames=True)
print(frames)

# Verify that one sample per frame was created
print(dataset.sum("metadata.total_frame_count"))  # 1279
print(len(frames))  # 1279

# View frames in the App
session.view = frames

```

```python
Dataset:     quickstart-video
Media type:  image
Num samples: 1279
Sample fields:
    id:               fiftyone.core.fields.ObjectIdField
    sample_id:        fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    frame_number:     fiftyone.core.fields.FrameNumberField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.ImageMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    detections:       fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
View stages:
    1. ToFrames(config=None)

```

The above example passes the `sample_frames=True` option to
[`to_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_frames "fiftyone.core.collections.SampleCollection.to_frames"),
which causes the necessary frames of the input video collection to be sampled
into directories of per-frame images on disk when the view is created.
**For large video datasets, this may take some time and require substantial**
**disk space.** The paths to each frame image will also be stored in a `filepath`
field of each [`Frame`](../api/fiftyone.core.frame.html#fiftyone.core.frame.Frame "fiftyone.core.frame.Frame") of the source collection.

Note that, when using the `sample_frames=True` option, frames that have
previously been sampled will not be resampled, so creating frame views into the
same dataset will become faster after the frames have been sampled.

Note

The recommended way to use
[`to_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_frames "fiftyone.core.collections.SampleCollection.to_frames")
is to first populate the `filepath` field of each [`Frame`](../api/fiftyone.core.frame.html#fiftyone.core.frame.Frame "fiftyone.core.frame.Frame") of your dataset
offline, either by running it once with the `sample_frames=True` option or
by manually sampling the frames yourself and populating the `filepath`
frame field.

Then you can work with frame views efficiently via the default syntax:

```python
# Creates a view with one sample per frame whose `filepath` is set
frames = dataset.to_frames()

```

More generally,
[`to_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_frames "fiftyone.core.collections.SampleCollection.to_frames")
exposes a variety of parameters that you can use to configure the behavior of
the video-to-image conversion process. You can also combine
[`to_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_frames "fiftyone.core.collections.SampleCollection.to_frames") with
view stages like
[`match_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_frames "fiftyone.core.collections.SampleCollection.match_frames")
to achieve fine-grained control over the specific frames you want to study.

For example, the snippet below creates a frames view that only contains samples
for frames with at least 10 objects, sampling at most one frame per second:

```python
from fiftyone import ViewField as F

#
# Create a frames view that only contains frames with at least 10
# objects, sampled at a maximum frame rate of 1fps
#

num_objects = F("detections.detections").length()
view = dataset.match_frames(num_objects > 10)

frames = view.to_frames(max_fps=1)
print(frames)

# Compare the number of frames in each step
print(dataset.count("frames"))  # 1279
print(view.count("frames"))  # 354
print(len(frames))  # 13

# View frames in the App
session.view = frames

```

Frame views inherit all frame-level labels from the source video dataset,
including their frame number. Each frame sample is also given a `sample_id`
field that records the ID of the parent video sample, and any `tags` of the
parent video sample are also included.

Frame views are just like any other image collection view in the sense that:

- You can append view stages via the [App view bar](app.md#app-create-view) or
[views API](#using-views)

- Any modifications to label tags that you make via the App’s
[tagging menu](app.md#app-tagging) or via API methods like
[`tag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.tag_labels "fiftyone.core.collections.SampleCollection.tag_labels")
and [`untag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.untag_labels "fiftyone.core.collections.SampleCollection.untag_labels")
will be reflected on the source dataset

- Any edits (including additions, modifications, and deletions) to the fields
of the samples in a frames view that you make by iterating over the
contents of the view or calling
[`set_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_values "fiftyone.core.collections.SampleCollection.set_values")
or
[`set_label_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_label_values "fiftyone.core.collections.SampleCollection.set_label_values")
will be reflected on the source dataset

- Calling [`save()`](../api/fiftyone.core.video.html#fiftyone.core.video.FramesView.save "fiftyone.core.video.FramesView.save"),
[`keep()`](../api/fiftyone.core.video.html#fiftyone.core.video.FramesView.keep "fiftyone.core.video.FramesView.keep"), or
[`keep_fields()`](../api/fiftyone.core.video.html#fiftyone.core.video.FramesView.keep_fields "fiftyone.core.video.FramesView.keep_fields") on a
frames view (typically one that contains additional view stages that filter
or modify its contents) will sync any changes to the frames of the
underlying video dataset


The only way in which frames views differ from regular image collections is
that changes to the `tags` or `metadata` fields of frame samples will not
be propagated to the frames of the underlying video dataset.

### Frame patches views [¶](\#frame-patches-views "Permalink to this headline")

Since frame views into video datasets behave just like any other view, you can
chain
[`to_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_frames "fiftyone.core.collections.SampleCollection.to_frames") and
[`to_patches()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.to_patches "fiftyone.core.collections.SampleCollection.to_patches")
to create **frame patch views** into your video datasets that contain one
sample per object patch in the frames of the dataset!

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart-video")

session = fo.launch_app(dataset)

# Create a frames view
frames = dataset.to_frames(sample_frames=True)

# Create a frame patches view
frame_patches = frames.to_patches("detections")
print(frame_patches)

# Verify that one sample per object was created
print(dataset.count("frames.detections.detections"))  # 11345
print(len(frame_patches))  # 11345

# View frame patches in the App
session.view = frame_patches

```

```python
Dataset:     quickstart-video
Media type:  image
Num patches: 11345
Patch fields:
    id:               fiftyone.core.fields.ObjectIdField
    sample_id:        fiftyone.core.fields.ObjectIdField
    frame_id:         fiftyone.core.fields.ObjectIdField
    filepath:         fiftyone.core.fields.StringField
    frame_number:     fiftyone.core.fields.FrameNumberField
    tags:             fiftyone.core.fields.ListField(fiftyone.core.fields.StringField)
    metadata:         fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.ImageMetadata)
    created_at:       fiftyone.core.fields.DateTimeField
    last_modified_at: fiftyone.core.fields.DateTimeField
    detections:       fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detection)
View stages:
    1. ToFrames(config=None)
    2. ToPatches(field='detections', config=None)

```

### Querying frames [¶](\#querying-frames "Permalink to this headline")

You can query for a subset of the frames in a video dataset via
[`match_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_frames "fiftyone.core.collections.SampleCollection.match_frames").
The syntax is:

```python
match_view = dataset.match_frames(expression)

```

where `expression` defines the matching expression to use to decide whether
to include a frame in the view.

FiftyOne provides powerful [`ViewField`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewField "fiftyone.core.expressions.ViewField") and [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") classes that allow
you to use native Python operators to define your match expression. Simply wrap
the target frame field in a [`ViewField`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewField "fiftyone.core.expressions.ViewField") and then apply comparison, logic,
arithmetic or array operations to it to create a [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression"). You can use
[dot notation](https://docs.mongodb.com/manual/core/document/#dot-notation)
to refer to fields or subfields of the embedded documents in your frames.
Any resulting [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") that returns a boolean is a valid expression!

The snippet below demonstrates a possible workflow. See the API reference for
[`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") for a full list of supported operations.

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart-video")

# Create a view that only contains frames with at least 10 objects
num_objects = F("detections.detections").length()
view = dataset.match_frames(num_objects > 10)

# Compare the number of frames in each collection
print(dataset.count("frames"))  # 1279
print(view.count("frames"))  # 354

```

You can also use
[`select_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.select_frames "fiftyone.core.collections.SampleCollection.select_frames") and
[`exclude_frames()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.exclude_frames "fiftyone.core.collections.SampleCollection.exclude_frames")
to restrict attention to or exclude frames from a view by their IDs:

```python
# Get the IDs of a couple frames
frame_ids = [\
    dataset.first().frames.first().id,\
    dataset.last().frames.last().id,\
]

# Select only the specified frames
selected_view = dataset.select_frames(frame_ids)

# Exclude frames with the given IDs from the view
excluded_view = dataset.exclude_frames(frame_ids)

```

## Similarity views [¶](\#similarity-views "Permalink to this headline")

If your dataset is [indexed by similarity](brain.md#brain-similarity), then you
can use the
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
stage to programmatically query your data by similarity to image(s) or object
patch(es) of interest.

### Image similarity [¶](\#image-similarity "Permalink to this headline")

The example below indexes a dataset by image similarity using
`compute_similarity()` and then uses
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
to sort the dataset by similarity to a chosen image:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# Index the dataset by image similarity
fob.compute_similarity(dataset, brain_key="image_sim")

session = fo.launch_app(dataset)

# Select a random query image
query_id = dataset.take(1).first().id

# Sort the samples by similarity to the query image
view = dataset.sort_by_similarity(query_id, brain_key="image_sim")
print(view)

# View results in the App
session.view = view

```

Note

Refer to the [Brain guide](brain.md#brain-similarity) for more information
about generating similarity indexes, and check out the
[App guide](app.md#app-image-similarity) to see how to sort images by
similarity via point-and-click in the App!

### Object similarity [¶](\#object-similarity "Permalink to this headline")

The example below indexes the objects in a [`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections") field of a dataset by
similarity using
`compute_similarity()` and then uses
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
to retrieve the 15 most similar objects to a chosen object:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# Index the dataset by `ground_truth` object similarity
fob.compute_similarity(
    dataset, patches_field="ground_truth", brain_key="gt_sim"
)

# Convert to ground truth patches view
patches = dataset.to_patches("ground_truth")

# View patches in the App
session = fo.launch_app(view=patches)

# Select a random query object
query_id = patches.take(1).first().id

# Retrieve the 15 most similar objects
similar_objects = patches.sort_by_similarity(query_id, k=15, brain_key="gt_sim")

# View results in the App
session.view = similar_objects

```

Note

Refer to the [Brain guide](brain.md#brain-similarity) for more information
about generating similarity indexes, and check out the
[App guide](app.md#app-object-similarity) to see how to sort objects by
similarity via point-and-click in the App!

### Text similarity [¶](\#text-similarity "Permalink to this headline")

When you create a [similarity index](brain.md#brain-similarity) powered by the
[CLIP model](../models/model_zoo/models.md#model-zoo-clip-vit-base32-torch), you can pass arbitrary
natural language queries to
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
along with the `brain_key` of a compatible similarity index:

You can verify that a similarity index supports text queries by checking that
it `supports_prompts`:

```python
info = dataset.get_brain_info(brain_key)
print(info.config.supports_prompts)  # True

```

Note

Refer to the [Brain guide](brain.md#brain-similarity) for more information
about generating similarity indexes, and check out the
[App guide](app.md#app-text-similarity) to see how to sort objects by text
similarity via point-and-click in the App!

## Geolocation [¶](\#geolocation "Permalink to this headline")

If your samples have [geolocation data](using_datasets.md#geolocation), then you can
use the
[`geo_near()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.geo_near "fiftyone.core.collections.SampleCollection.geo_near") and
[`geo_within()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.geo_within "fiftyone.core.collections.SampleCollection.geo_within")
stages to filter your data based on their location.

For example, you can use
[`geo_near()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.geo_near "fiftyone.core.collections.SampleCollection.geo_near") to
sort your samples by proximity to a location:

```python
import fiftyone as fo
import fiftyone.zoo as foz

TIMES_SQUARE = [-73.9855, 40.7580]

dataset = foz.load_zoo_dataset("quickstart-geo")

# Sort the samples by their proximity to Times Square, and only include
# samples within 5km
view = dataset.geo_near(TIMES_SQUARE, max_distance=5000)

```

Or, you can use
[`geo_within()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.geo_within "fiftyone.core.collections.SampleCollection.geo_within") to
only include samples that lie within a longitude-latitude polygon of your
choice:

```python
import fiftyone as fo
import fiftyone.zoo as foz

MANHATTAN = [\
    [\
        [-73.949701, 40.834487],\
        [-73.896611, 40.815076],\
        [-73.998083, 40.696534],\
        [-74.031751, 40.715273],\
        [-73.949701, 40.834487],\
    ]\
]

dataset = foz.load_zoo_dataset("quickstart-geo")

# Only contains samples in Manhattan
view = dataset.geo_within(MANHATTAN)

```

## Tagging contents [¶](\#tagging-contents "Permalink to this headline")

You can use the
[`tag_samples()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.tag_samples "fiftyone.core.collections.SampleCollection.tag_samples")
and [`untag_samples()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.untag_samples "fiftyone.core.collections.SampleCollection.untag_samples")
methods to add or remove [sample tags](using_datasets.md#using-tags) from the samples in a
view:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")
dataset.untag_samples("validation") # remove pre-existing tags

# Perform a random 90-10 test-train split
dataset.take(0.1 * len(dataset)).tag_samples("test")
dataset.match_tags("test", bool=False).tag_samples("train")

print(dataset.count_sample_tags())
# {'train': 180, 'test': 20}

```

You can also use the
[`tag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.tag_labels "fiftyone.core.collections.SampleCollection.tag_labels")
and [`untag_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.untag_labels "fiftyone.core.collections.SampleCollection.untag_labels")
methods to add or remove [label tags](using_datasets.md#label-tags) from the labels in one
or more fields of a view:

```python
# Add a tag to all low confidence predictions
view = dataset.filter_labels("predictions", F("confidence") < 0.06)
view.tag_labels("low_confidence", label_fields="predictions")

print(dataset.count_label_tags())
# {'low_confidence': 447}

```

## Editing fields [¶](\#editing-fields "Permalink to this headline")

You can perform arbitrary edits to a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") by iterating over its
contents and editing the samples directly:

```python
import random

import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")

view = dataset.limit(50)

# Populate a new field on each sample in the view
for sample in view:
    sample["random"] = random.random()
    sample.save()

print(dataset.count("random"))  # 50
print(dataset.bounds("random")) # (0.0005, 0.9928)

```

However, the above pattern can be inefficient for large views because each
[`sample.save()`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView.save "fiftyone.core.sample.SampleView.save") call makes a new
connection to the database.

The [`iter_samples()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.iter_samples "fiftyone.core.view.DatasetView.iter_samples") method
provides an `autosave=True` option that causes all changes to samples
emitted by the iterator to be automatically saved using an efficient batch
update strategy:

```python
# Automatically saves sample edits in efficient batches
for sample in view.select_fields().iter_samples(autosave=True):
    sample["random"] = random.random()

```

Note

As the above snippet shows, you should also optimize your iteration by
[selecting only](#efficient-iteration-views) the required fields.

You can configure the default batching strategy that is used via your
[FiftyOne config](config.md#configuring-fiftyone), or you can configure the
batching strategy on a per-method call basis by passing the optional
`batch_size` and `batching_strategy` arguments to
[`iter_samples()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.iter_samples "fiftyone.core.view.DatasetView.iter_samples").

You can also use the
[`save_context()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.save_context "fiftyone.core.collections.SampleCollection.save_context")
method to perform batched edits using the pattern below:

```python
# Use a context to save sample edits in efficient batches
with view.save_context() as context:
    for sample in view.select_fields():
        sample["random"] = random.random()
        context.save(sample)

```

The benefit of the above approach versus passing `autosave=True` to
[`iter_samples()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.iter_samples "fiftyone.core.view.DatasetView.iter_samples") is that
[`context.save()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SaveContext.save "fiftyone.core.collections.SaveContext.save") allows you
to be explicit about which samples you are editing, which avoids unnecessary
computations if your loop only edits certain samples.

Another strategy for performing efficient batch edits is to use
[`set_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_values "fiftyone.core.collections.SampleCollection.set_values") to
set a field (or embedded field) on each sample in the collection in a single
batch operation:

```python
# Delete the field we added earlier
dataset.delete_sample_field("random")

# Equivalent way to populate a new field on each sample in a view
values = [random.random() for _ in range(len(view))]
view.set_values("random", values)

print(dataset.count("random"))  # 50
print(dataset.bounds("random")) # (0.0272, 0.9921)

```

Note

When possible, using
[`set_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_values "fiftyone.core.collections.SampleCollection.set_values")
is often more efficient than performing the equivalent operation via an
explicit iteration over the [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") because it avoids the need to
read [`SampleView`](../api/fiftyone.core.sample.html#fiftyone.core.sample.SampleView "fiftyone.core.sample.SampleView") instances into memory and sequentially save them.

Naturally, you can edit nested sample fields of a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") by iterating
over the view and editing the necessary data:

```python
# Create a view that contains only low confidence predictions
view = dataset.filter_labels("predictions", F("confidence") < 0.06)

# Add a tag to all predictions in the view
for sample in view:
    for detection in sample["predictions"].detections:
        detection.tags.append("low_confidence")

    sample.save()

print(dataset.count_label_tags())
# {'low_confidence': 447}

```

However, an equivalent and often more efficient approach is to use
[`values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.values "fiftyone.core.collections.SampleCollection.values") to
extract the slice of data you wish to modify and then use
[`set_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_values "fiftyone.core.collections.SampleCollection.set_values") to
save the updated data in a single batch operation:

```python
# Remove the tags we added in the previous variation
dataset.untag_labels("low_confidence")

# Load all predicted detections
# This is a list of lists of `Detection` instances for each sample
detections = view.values("predictions.detections")

# Add a tag to all low confidence detections
for sample_detections in detections:
    for detection in sample_detections:
        detection.tags.append("low_confidence")

# Save the updated predictions
view.set_values("predictions.detections", detections)

print(dataset.count_label_tags())
# {'low_confidence': 447}

```

In the particular case of updating the attributes of a [`Label`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Label "fiftyone.core.labels.Label") field of your
dataset, the edits may be most naturally represented as a mapping between label
IDs and corresponding attribute values to set on each label. In such cases, you
can use
[`set_label_values()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_label_values "fiftyone.core.collections.SampleCollection.set_label_values")
to conveniently perform the updates:

```python
# Grab the IDs of all labels in `view`
label_ids = view.values("predictions.detections.id", unwind=True)

# Populate an `is_low_conf` attribute on all of the labels
values = {_id: True for _id in label_ids}
dataset.set_label_values("predictions.detections.is_low_conf", values)

print(dataset.count_values("predictions.detections.is_low_conf"))
# {True: 447, None: 5173}

```

## Transforming fields [¶](\#transforming-fields "Permalink to this headline")

In certain situations, you may wish to temporarily modify the values of sample
fields in the context of a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") without modifying the underlying
dataset. FiftyOne provides the
[`set_field()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_field "fiftyone.core.collections.SampleCollection.set_field")
and
[`map_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.map_labels "fiftyone.core.collections.SampleCollection.map_labels")
methods for this purpose.

For example, suppose you would like to rename a group of labels to a single
category in order to run your evaluation routine. You can use
[`map_labels()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.map_labels "fiftyone.core.collections.SampleCollection.map_labels")
to do this:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")

ANIMALS = [\
    "bear", "bird", "cat", "cow", "dog", "elephant", "giraffe",\
    "horse", "sheep", "zebra"\
]

# Replace all animal detection's labels with "animal"
mapping = {k: "animal" for k in ANIMALS}
animals_view = dataset.map_labels("predictions", mapping)

counts = animals_view.count_values("predictions.detections.label")
print(counts["animal"])
# 529

```

Or, suppose you would like to lower bound all confidences of objects in the
`predictions` field of a dataset. You can use
[`set_field()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_field "fiftyone.core.collections.SampleCollection.set_field")
to do this:

```python
# Lower bound all confidences in the `predictions` field to 0.5
bounded_view = dataset.set_field(
    "predictions.detections.confidence",
    F("confidence").max(0.5),
)

print(bounded_view.bounds("predictions.detections.confidence"))
# (0.5, 0.9999035596847534)

```

Note

In order to populate a _new field_ using
[`set_field()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.set_field "fiftyone.core.collections.SampleCollection.set_field"),
you must first declare the new field on the dataset via
[`add_sample_field()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.add_sample_field "fiftyone.core.dataset.Dataset.add_sample_field"):

```python
# Record the number of predictions in each sample in a new field
dataset.add_sample_field("num_predictions", fo.IntField)
view = dataset.set_field("num_predictions", F("predictions.detections").length())

view.save("num_predictions")  # save the new field's values on the dataset
print(dataset.bounds("num_predictions"))  # (1, 100)

```

The [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression") language is quite powerful, allowing you to define complex
operations without needing to write an explicit Python loop to perform the
desired manipulation.

For example, the snippet below visualizes the top-5 highest confidence
predictions for each sample in the dataset:

```python
from fiftyone import ViewField as F

# Extracts the 5 highest confidence predictions for each sample
top5_preds = F("detections").sort("confidence", reverse=True)[:5]

top5_view = (
    dataset
    .set_field("predictions.detections", top5_preds)
    .select_fields("predictions")
)

session = fo.launch_app(view=top5_view)

```

If you want to permanently save transformed view fields to the underlying
dataset, you can do so by calling
[`save()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.save "fiftyone.core.view.DatasetView.save") on the view and optionally
passing the name(s) of specific field(s) that you want to save:

```python
# Saves `predictions` field's contents in the view permanently to dataset
top5_view.save("predictions")

```

## Saving and cloning [¶](\#saving-and-cloning "Permalink to this headline")

Ordinarily, when you define a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") that extracts a specific subset of
a dataset and its fields, the underlying [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") is not modified. However,
you can use [`save()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.save "fiftyone.core.view.DatasetView.save") to save the
contents of a view you’ve created to the underlying dataset:

```python
import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

dataset = foz.load_zoo_dataset("quickstart")

# Capitalize some labels
rename_view = dataset.map_labels("predictions", {"cat": "CAT", "dog": "DOG"})
rename_view.save()

print(dataset.count_values("predictions.detections.label"))
# {'CAT': 35, 'DOG': 49, ...}

# Discard all predictions with confidence below 0.3
high_conf_view = dataset.filter_labels(
    "predictions", F("confidence") > 0.3, only_matches=False
)
high_conf_view.save()

print(dataset.bounds("predictions.detections.confidence"))
# (0.3001, 0.9999)

```

Note that calling [`save()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.save "fiftyone.core.view.DatasetView.save") on a
[`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") will only save modifications to samples that are in the view; all
other samples are left unchanged.

You can use [`keep()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.keep "fiftyone.core.view.DatasetView.keep") to delete
samples from the underlying dataset that do not appear in a view you created:

```python
print(len(dataset))
# 200

# Discard all samples with no people
people_view = dataset.filter_labels("ground_truth", F("label") == "person")
people_view.keep()

print(len(dataset))
# 94

```

and you can use
[`keep_fields()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.keep_fields "fiftyone.core.view.DatasetView.keep_fields")
to delete any sample/frame fields from the underlying dataset that you have
excluded from a view you created:

```python
# Delete the `predictions` field
view = dataset.exclude_fields("predictions")
view.keep_fields()

print(dataset)

# Delete all non-default fields
view = dataset.select_fields()
view.keep_fields()

print(dataset)

```

Alternatively, you can use
[`clone()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.clone "fiftyone.core.view.DatasetView.clone") to create a new
[`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") that contains a copy of (only) the contents of a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView"):

```python
# Reload full quickstart dataset
dataset.delete()
dataset = foz.load_zoo_dataset("quickstart")

# Create a new dataset that contains only the high confidence predictions
high_conf_view = dataset.filter_labels("predictions", F("confidence") > 0.3)
high_conf_dataset = high_conf_view.clone()

print(high_conf_dataset.bounds("predictions.detections.confidence"))
# (0.3001, 0.9999)

```

You can also use
[`clone_sample_field()`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView.clone_sample_field "fiftyone.core.view.DatasetView.clone_sample_field")
to copy the contents of a view’s field into a new field of the underlying
[`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset"):

```python
print(dataset.count("predictions.detections"))  # 5620

# Make view containing only high confidence predictions
view = dataset.filter_labels("predictions", F("confidence") > 0.5)
print(view.count("predictions.detections"))  # 1564

# Copy high confidence predictions to a new field
view.clone_sample_field("predictions", "high_conf_predictions")
print(dataset.count("high_conf_predictions.detections"))  # 1564

```

## Tips & tricks [¶](\#tips-tricks "Permalink to this headline")

### Chaining view stages [¶](\#chaining-view-stages "Permalink to this headline")

View stages can be chained together to perform complex operations:

```python
from fiftyone import ViewField as F

# Extract the first 5 samples with the "validation" tag, alphabetically by
# filepath, whose images are >= 48 KB
complex_view = (
    dataset
    .match_tags("validation")
    .exists("metadata")
    .match(F("metadata.size_bytes") >= 48 * 1024)  # >= 48 KB
    .sort_by("filepath")
    .limit(5)
)

```

### Filtering detections by area [¶](\#filtering-detections-by-area "Permalink to this headline")

Need to filter your detections by bounding box area? Use this [`ViewExpression`](../api/fiftyone.core.expressions.html#fiftyone.core.expressions.ViewExpression "fiftyone.core.expressions.ViewExpression")!

```python
from fiftyone import ViewField as F

# Bboxes are in [top-left-x, top-left-y, width, height] format
bbox_area = F("bounding_box")[2] * F("bounding_box")[3]

# Only contains boxes whose area is between 5% and 50% of the image
medium_boxes_view = dataset.filter_labels(
    "predictions", (0.05 <= bbox_area) & (bbox_area < 0.5)
)

```

FiftyOne stores bounding box coordinates as relative values in `[0, 1]`.
However, you can use the expression below to filter by absolute pixel area:

```python
from fiftyone import ViewField as F

dataset.compute_metadata()

# Computes the area of each bounding box in pixels
bbox_area = (
    F("$metadata.width") * F("bounding_box")[2] *
    F("$metadata.height") * F("bounding_box")[3]
)

# Only contains boxes whose area is between 32^2 and 96^2 pixels
medium_boxes_view = dataset.filter_labels(
    "predictions", (32 ** 2 < bbox_area) & (bbox_area < 96 ** 2)
)

```

### Removing a batch of samples from a dataset [¶](\#removing-a-batch-of-samples-from-a-dataset "Permalink to this headline")

You can easily remove a batch of samples from a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") by constructing a
[`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") that contains the samples, and then deleting them from the
dataset as follows:

```python
# Choose 10 samples at random
unlucky_samples = dataset.take(10)

dataset.delete_samples(unlucky_samples)

```

### Efficiently iterating samples [¶](\#efficiently-iterating-samples "Permalink to this headline")

If you have a dataset with larger fields, such as [`Classifications`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Classifications "fiftyone.core.labels.Classifications") or
[`Detections`](../api/fiftyone.core.labels.html#fiftyone.core.labels.Detections "fiftyone.core.labels.Detections"), it can be expensive to load entire samples into memory. If, for a
particular use case, you are only interested in a
subset of fields, you can use
[`Dataset.select_fields()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.select_fields "fiftyone.core.dataset.Dataset.select_fields")
to load only the fields of interest.

Let’s say you have a dataset that looks like this:

```python
Name:        open-images-v4-test
Media type:  image
Num samples: 1000
Persistent:  True
Tags:        []
Sample fields:
    id:                       fiftyone.core.fields.ObjectIdField
    filepath:                 fiftyone.core.fields.StringField
    tags:                     fiftyone.core.fields.ListField(StringField)
    metadata:                 fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.metadata.ImageMetadata)
    created_at:               fiftyone.core.fields.DateTimeField
    last_modified_at:         fiftyone.core.fields.DateTimeField
    open_images_id:           fiftyone.core.fields.StringField
    groundtruth_image_labels: fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Classifications)
    groundtruth_detections:   fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
    faster_rcnn:              fiftyone.core.fields.EmbeddedDocumentField(fiftyone.core.labels.Detections)
    mAP:                      fiftyone.core.fields.FloatField
    AP_per_class:             fiftyone.core.fields.DictField

```

and you want to get a list of `open_images_id`’s for all samples in the
dataset. Loading other fields is unnecessary; in fact, using
[`Dataset.select_fields()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.select_fields "fiftyone.core.dataset.Dataset.select_fields")
to load only the `open_images_id` field speeds up the operation below by
~200X!

```python
import time

start = time.time()
oids = []
for sample in dataset:
    oids.append(sample.open_images_id)

print(time.time() - start)
# 38.212332010269165

start = time.time()
oids = []
for sample in dataset.select_fields("open_images_id"):
    oids.append(sample.open_images_id)

print(time.time() - start)
# 0.20824909210205078

```

