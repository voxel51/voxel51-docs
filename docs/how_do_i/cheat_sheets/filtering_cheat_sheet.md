# Filtering Cheat Sheet [¶](\#filtering-cheat-sheet "Permalink to this headline")

This cheat sheet shows how to perform common matching and filtering operations
in FiftyOne using [dataset views](../../fiftyone_concepts/using_views.md#using-views).

## Strings and pattern matching [¶](\#strings-and-pattern-matching "Permalink to this headline")

The formulas in this section use the following example data:

```python
import fiftyone.zoo as foz
from fiftyone import ViewField as F

ds = foz.load_zoo_dataset("quickstart")

```

| Operation | Command |
| --- | --- |
| Filepath starts with “/Users” | ```<br>ds.match(F("filepath").starts_with("/Users"))<br>``` |
| Filepath ends with “10.jpg” or “10.png” | ```<br>ds.match(F("filepath").ends_with(("10.jpg", "10.png"))<br>``` |
| Label contains string “be” | ```<br>ds.filter_labels(<br>    "predictions",<br>    F("label").contains_str("be"),<br>)<br>``` |
| Filepath contains “088” and is JPEG | ```<br>ds.match(F("filepath").re_match("088*.jpg"))<br>``` |

Reference:
[`match()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match "fiftyone.core.collections.SampleCollection.match") and
[`filter_labels()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_labels "fiftyone.core.collections.SampleCollection.filter_labels").

## Dates and times [¶](\#dates-and-times "Permalink to this headline")

The formulas in this section use the following example data:

```python
from datetime import datetime, timedelta

import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

filepaths = ["image%d.jpg" % i for i in range(5)]
dates = [\
    datetime(2021, 8, 24, 1, 0, 0),\
    datetime(2021, 8, 24, 2, 0, 0),\
    datetime(2021, 8, 25, 3, 11, 12),\
    datetime(2021, 9, 25, 4, 22, 23),\
    datetime(2022, 9, 27, 5, 0, 0)\
]

ds = fo.Dataset()
ds.add_samples(
    [fo.Sample(filepath=f, date=d) for f, d in zip(filepaths, dates)]
)

# Example data
query_date = datetime(2021, 8, 24, 2, 0, 1)
query_delta = timedelta(minutes=30)

```

| Operation | Command |
| --- | --- |
| After 2021-08-24 02:01:00 | ```<br>ds.match(F("date") > query_date)<br>``` |
| Within 30 minutes of 2021-08-24 02:01:00 | ```<br>ds.match(abs(F("date") - query_date) < query_delta)<br>``` |
| On the 24th of the month | ```<br>ds.match(F("date").day_of_month() == 24)<br>``` |
| On even day of the week | ```<br>ds.match(F("date").day_of_week() % 2 == 0)<br>``` |
| On the 268th day of the year | ```<br>ds.match(F("date").day_of_year() == 268)<br>``` |
| In the 9th month of the year (September) | ```<br>ds.match(F("date").month() == 9)<br>``` |
| In the 38th week of the year | ```<br>ds.match(F("date").week() == 38)<br>``` |
| In the year 2022 | ```<br>ds.match(F("date").year() == 2022)<br>``` |
| With minute not equal to 0 | ```<br>ds.match(F("date").minute() != 0)<br>``` |

Reference:
[`match()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match "fiftyone.core.collections.SampleCollection.match").

## Geospatial [¶](\#geospatial "Permalink to this headline")

The formulas in this section use the following example data:

```python
import fiftyone.zoo as foz

TIMES_SQUARE = [-73.9855, 40.7580]
MANHATTAN = [\
    [\
        [-73.949701, 40.834487],\
        [-73.896611, 40.815076],\
        [-73.998083, 40.696534],\
        [-74.031751, 40.715273],\
        [-73.949701, 40.834487],\
    ]\
]

ds = foz.load_zoo_dataset("quickstart-geo")

```

| Operation | Command |
| --- | --- |
| Within 5km of Times Square | ```<br>ds.geo_near(TIMES_SQUARE, max_distance=5000)<br>``` |
| Within Manhattan | ```<br>ds.geo_within(MANHATTAN)<br>``` |

Reference:
[`geo_near()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.geo_near "fiftyone.core.collections.SampleCollection.geo_near") and
[`geo_within()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.geo_within "fiftyone.core.collections.SampleCollection.geo_within").

## Detections [¶](\#detections "Permalink to this headline")

The formulas in this section use the following example data:

```python
import fiftyone.zoo as foz
from fiftyone import ViewField as F

ds = foz.load_zoo_dataset("quickstart")

```

| Operation | Command |
| --- | --- |
| Predictions with confidence > 0.95 | ```<br>ds.filter_labels("predictions", F("confidence") > 0.95)<br>``` |
| Exactly 10 ground truth detections | ```<br>ds.match(F("ground_truth.detections").length() == 10)<br>``` |
| At least one dog | ```<br>ds.match(<br>    F("ground_truth.detections.label").contains("dog")<br>)<br>``` |
| Images that do not contain dogs | ```<br>ds.match(<br>    ~F("ground_truth.detections.label").contains("dog")<br>)<br>``` |
| Only dog detections | ```<br>ds.filter_labels("ground_truth", F("label") == "dog")<br>``` |
| Images that only contain dogs | ```<br>ds.match(<br>    F("ground_truth.detections.label").is_subset(<br>        ["dog"]<br>    )<br>)<br>``` |
| Contains either a cat or a dog | ```<br>ds.match(<br>     F("predictions.detections.label").contains(<br>        ["cat","dog"]<br>     )<br>)<br>``` |
| Contains a cat and a dog prediction | ```<br>ds.match(<br>    F("predictions.detections.label").contains(<br>        ["cat", "dog"], all=True<br>    )<br>)<br>``` |
| Contains a cat or dog but not both | ```<br>field = "predictions.detections.label"<br>one_expr = F(field).contains(["cat", "dog"])<br>both_expr = F(field).contains(["cat", "dog"], all=True)<br>ds.match(one_expr & ~both_expr)<br>``` |

Reference:
[`match()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match "fiftyone.core.collections.SampleCollection.match") and
[`filter_labels()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_labels "fiftyone.core.collections.SampleCollection.filter_labels").

### Bounding boxes [¶](\#bounding-boxes "Permalink to this headline")

The formulas in this section assume the following code has been run:

```python
import fiftyone.zoo as foz
from fiftyone import ViewField as F

ds = foz.load_zoo_dataset("quickstart")

box_width, box_height = F("bounding_box")[2], F("bounding_box")[3]
rel_bbox_area = box_width * box_height

im_width, im_height = F("$metadata.width"), F("$metadata.height")
abs_area = rel_bbox_area * im_width * im_height

```

| Bounding box query | Command |
| --- | --- |
| Larger than absolute size | ```<br>ds.filter_labels("predictions", abs_area > 96**2)<br>``` |
| Between two relative sizes | ```<br>good_bboxes = (rel_bbox_area > 0.25) & (rel_bbox_area < 0.75)<br>good_expr = rel_bbox_area.let_in(good_bboxes)<br>ds.filter_labels("predictions", good_expr)<br>``` |
| Approximately square | ```<br>rectangleness = abs(<br>    box_width * im_width - box_height * im_height<br>)<br>ds.select_fields("predictions").filter_labels(<br>    "predictions", rectangleness <= 1<br>)<br>``` |
| Aspect ratio > 2 | ```<br>aspect_ratio = (<br>    (box_width * im_width) / (box_height * im_height)<br>)<br>ds.select_fields("predictions").filter_labels(<br>    "predictions", aspect_ratio > 2<br>)<br>``` |

Reference:
[`filter_labels()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_labels "fiftyone.core.collections.SampleCollection.filter_labels")
and
[`select_fields()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.select_fields "fiftyone.core.collections.SampleCollection.select_fields").

### Evaluating detections [¶](\#evaluating-detections "Permalink to this headline")

The formulas in this section assume the following code has been run on a
dataset `ds` with detections in its `predictions` field:

```python
import fiftyone.brain as fob
import fiftyone.zoo as foz
from fiftyone import ViewField as F

ds = foz.load_zoo_dataset("quickstart")

ds.evaluate_detections("predictions", eval_key="eval")

fob.compute_uniqueness(ds)
fob.compute_mistakenness(ds, "predictions", label_field="ground_truth")
ep = ds.to_evaluation_patches("eval")

```

| Operation | Command |
| --- | --- |
| Uniqueness > 0.9 | ```<br>ds.match(F("uniqueness") > 0.9)<br>``` |
| 10 most unique images | ```<br>ds.sort_by("uniqueness", reverse=True)[:10]<br>``` |
| Predictions with confidence > 0.95 | ```<br>ds.filter_labels("predictions", F("confidence") > 0.95)<br>``` |
| 10 most “wrong” predictions | ```<br>ds.sort_by("mistakenness", reverse=True)[:10]<br>``` |
| Images with more than 10 false positives | ```<br>ds.match(F("eval_fp") > 10)<br>``` |
| False positive “dog” detections | ```<br>ep.match_labels(<br>   filter=(F("eval") == "fp") & (F("label") == "dog"),<br>   fields="predictions",<br>)<br>``` |
| Predictions with IoU > 0.9 | ```<br>ep.match(F("iou") > 0.9)<br>``` |

Reference:
[`match()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match "fiftyone.core.collections.SampleCollection.match"),
[`sort_by()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by "fiftyone.core.collections.SampleCollection.sort_by"),
[`filter_labels()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_labels "fiftyone.core.collections.SampleCollection.filter_labels"),
and
[`match_labels()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_labels "fiftyone.core.collections.SampleCollection.match_labels").

## Classifications [¶](\#classifications "Permalink to this headline")

### Evaluating classifications [¶](\#evaluating-classifications "Permalink to this headline")

The formulas in the following table assumes the following code has been run on
a dataset `ds`, where the `predictions` field is populated with
classification predictions that have their `logits` attribute set:

```python
import fiftyone.brain as fob
import fiftyone.zoo as foz

ds = foz.load_zoo_dataset("cifar10", split="test")

# TODO: add your own predicted classifications

ds.evaluate_classifications("predictions", gt_field="ground_truth")

fob.compute_uniqueness(ds)
fob.compute_hardness(ds, "predictions")
fob.compute_mistakenness(ds, "predictions", label_field="ground_truth")

```

| Operation | Command |
| --- | --- |
| 10 most unique incorrect predictions | ```<br>ds.match(<br>    F("predictions.label") != F("ground_truth.label")<br>).sort_by("uniqueness", reverse=True)[:10]<br>``` |
| 10 most “wrong” predictions | ```<br>ds.sort_by("mistakenness", reverse=True)[:10]<br>``` |
| 10 most likely annotation mistakes | ```<br>ds.match_tags("train").sort_by(<br>    "mistakenness", reverse=True<br>)[:10]<br>``` |

Reference:
[`match()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match "fiftyone.core.collections.SampleCollection.match"),
[`sort_by()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by "fiftyone.core.collections.SampleCollection.sort_by"),
and
[`match_tags()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_tags "fiftyone.core.collections.SampleCollection.match_tags").

## Built-in filter and match functions [¶](\#built-in-filter-and-match-functions "Permalink to this headline")

FiftyOne has special methods for matching and filtering on specific data types.
Take a look at the examples in this section to see how various operations can
be performed via these special purpose methods, and compare that to the brute
force implementation of the same operation that follows.

The tables in this section use the following example data:

```python
from bson import ObjectId

import fiftyone as fo
import fiftyone.zoo as foz
from fiftyone import ViewField as F

ds = foz.load_zoo_dataset("quickstart")

# Tag a few random samples
ds.take(3).tag_labels("potential_mistake", label_fields="predictions")

# Grab a few label IDs
label_ids = [\
    dataset.first().ground_truth.detections[0].id,\
    dataset.last().predictions.detections[0].id,\
]
ds.select_labels(ids=label_ids).tag_labels("error")

len_filter = F("label").strlen() < 3
id_filter = F("_id").is_in([ObjectId(_id) for _id in label_ids])

```

### Filtering labels [¶](\#filtering-labels "Permalink to this headline")

| Operation | Get predicted detections that have confidence > 0.9 |
| --- | --- |
| Idiomatic | ```<br>ds.filter_labels("predictions", F("confidence") > 0.9)<br>``` |
| Brute force | ```<br>ds.set_field(<br>    "predictions.detections",<br>    F("detections").filter(F("confidence") > 0.9)),<br>)<br>``` |

Reference:
[`filter_labels()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_labels "fiftyone.core.collections.SampleCollection.filter_labels").

### Matching labels [¶](\#matching-labels "Permalink to this headline")

| Operation | Samples that have labels with id’s in the list `label_ids` |
| --- | --- |
| Idiomatic | ```<br>ds.match_labels(ids=label_ids)<br>``` |
| Brute force | ```<br>pred_expr = F("predictions.detections").filter(id_filter).length() > 0<br>gt_expr = F("ground_truth.detections").filter(id_filter).length() > 0<br>ds.match(pred_expr | gt_expr)<br>``` |

| Operation | Samples that have labels satisfying `len_filter` in `predictions` or `ground_truth` field |
| --- | --- |
| Idiomatic | ```<br>ds.match_labels(<br>    filter=len_filter,<br>    fields=["predictions", "ground_truth"],<br>)<br>``` |
| Brute force | ```<br>pred_expr = F("predictions.detections").filter(len_filter).length() > 0<br>gt_expr = F("ground_truth.detections").filter(len_filter).length() > 0<br>ds.match(pred_expr | gt_expr)<br>``` |

| Operation | Samples that have labels with tag “error” in `predictions` or `ground_truth` field |
| --- | --- |
| Idiomatic | ```<br>ds.match_labels(tags="error")<br>``` |
| Brute force | ```<br>tag_expr = F("tags").contains("error")<br>pred_expr = F("predictions.detections").filter(tag_expr).length() > 0<br>gt_expr = F("ground_truth.detections").filter(tag_expr).length() > 0<br>ds.match(pred_expr | gt_expr)<br>``` |

Reference:
[`match_labels()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_labels "fiftyone.core.collections.SampleCollection.match_labels").

### Matching tags [¶](\#matching-tags "Permalink to this headline")

| Operation | Samples that have tag `validation` |
| --- | --- |
| Idiomatic | ```<br>ds.match_tags("validation")<br>``` |
| Brute force | ```<br>ds.match(F("tags").contains("validation"))<br>``` |

Reference:
[`match_tags()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_tags "fiftyone.core.collections.SampleCollection.match_tags").

### Matching frames [¶](\#matching-frames "Permalink to this headline")

The following table uses this example data:

```python
import fiftyone.zoo as foz
from fiftyone import ViewField as F

ds = foz.load_zoo_dataset("quickstart-video")
num_objects = F("detections.detections").length()

```

| Operation | Frames with at least 10 detections |
| --- | --- |
| Idiomatic | ```<br>ds.match_frames(num_objects > 10)<br>``` |
| Brute force | ```<br>ds.match(F("frames").filter(num_objects > 10).length() > 0)<br>``` |

Reference:
[`match_frames()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_frames "fiftyone.core.collections.SampleCollection.match_frames").

### Filtering keypoints [¶](\#filtering-keypoints "Permalink to this headline")

You can use
[`filter_keypoints()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.filter_keypoints "fiftyone.core.collections.SampleCollection.filter_keypoints")
to retrieve individual keypoints within a [`Keypoint`](../../api/fiftyone.core.labels.html#fiftyone.core.labels.Keypoint "fiftyone.core.labels.Keypoint") instance that match a
specified condition.

The following table uses this example data:

```python
import fiftyone as fo
from fiftyone import ViewField as F

ds = fo.Dataset()
ds.add_samples(
    [\
        fo.Sample(\
            filepath="image1.jpg",\
            predictions=fo.Keypoints(\
                keypoints=[\
                    fo.Keypoint(\
                        label="person",\
                        points=[(0.1, 0.1), (0.1, 0.9), (0.9, 0.9), (0.9, 0.1)],\
                        confidence=[0.7, 0.8, 0.95, 0.99],\
                    )\
                ]\
            )\
        ),\
        fo.Sample(filepath="image2.jpg"),\
    ]
)

ds.default_skeleton = fo.KeypointSkeleton(
    labels=["nose", "left eye", "right eye", "left ear", "right ear"],
    edges=[[0, 1, 2, 0], [0, 3], [0, 4]],
)

```

| Operation | Only include predicted keypoints with confidence > 0.9 |
| --- | --- |
| Idiomatic | ```<br>ds.filter_keypoints("predictions", filter=F("confidence") > 0.9)<br>``` |
| Brute force | ```<br>tmp = ds.clone()<br>for sample in tmp.iter_samples(autosave=True):<br>    if sample.predictions is None:<br>        continue<br>    for keypoint in sample.predictions.keypoints:<br>        for i, confidence in enumerate(keypoint.confidence):<br>            if confidence <= 0.9:<br>                keypoint.points[i] = [None, None]<br>``` |

Reference:
[`match_frames()`](../../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.match_frames "fiftyone.core.collections.SampleCollection.match_frames").

