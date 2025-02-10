# Super Gradients Integration [¶](\#super-gradients-integration "Permalink to this headline")

FiftyOne integrates natively with Deci AI’s
[SuperGradients](https://github.com/Deci-AI/super-gradients) library, so you
can run inference with YOLO-NAS architectures on your FiftyOne datasets with
just a few lines of code!

## Setup [¶](\#setup "Permalink to this headline")

To get started with
[SuperGradients](https://github.com/Deci-AI/super-gradients), just install
the `super-gradients` package:

```python
pip install super-gradients

```

## Inference [¶](\#inference "Permalink to this headline")

You can directly pass SuperGradients YOLO-NAS models to your FiftyOne dataset’s
[`apply_model()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.apply_model "fiftyone.core.collections.SampleCollection.apply_model")
method:

```python
import fiftyone as fo
import fiftyone.zoo as foz

from super_gradients.training import models

dataset = foz.load_zoo_dataset("quickstart", max_samples=25)
dataset.select_fields().keep_fields()

model = models.get("yolo_nas_m", pretrained_weights="coco")
# model = models.get("yolo_nas_l", pretrained_weights="coco")
# model = models.get("yolo_nas_s", pretrained_weights="coco")

dataset.apply_model(model, label_field="yolo_nas", confidence_thresh=0.7)

session = fo.launch_app(dataset)

```

## Model zoo [¶](\#model-zoo "Permalink to this headline")

SuperGradients YOLO-NAS is also available directly from the
[FiftyOne Model Zoo](../models/model_zoo/models.md#model-zoo-yolo-nas-torch)!

```python
import fiftyone as fo
import fiftyone.zoo as foz

model = foz.load_zoo_model("yolo-nas-torch")

dataset = foz.load_zoo_dataset("quickstart")
dataset.apply_model(model, label_field="yolo_nas")

session = fo.launch_app(dataset)

```

