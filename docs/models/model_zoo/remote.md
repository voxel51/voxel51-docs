# Remotely-Sourced Zoo Models [¶](\#remotely-sourced-zoo-models "Permalink to this headline")

This page describes how to work with and create zoo models whose definitions
are hosted via GitHub repositories or public URLs.

Note

To download from a private GitHub repository that you have access to,
provide your GitHub personal access token by setting the `GITHUB_TOKEN`
environment variable.

## Working with remotely-sourced models [¶](\#working-with-remotely-sourced-models "Permalink to this headline")

Working with remotely-sourced zoo models is just like
[built-in zoo models](models.md#model-zoo-models), as both varieties support
the [full zoo API](api.md#model-zoo-api).

When specifying remote sources, you can provide any of the following:

- A GitHub repo URL like `https://github.com/<user>/<repo>`

- A GitHub ref like `https://github.com/<user>/<repo>/tree/<branch>` or
`https://github.com/<user>/<repo>/commit/<commit>`

- A GitHub ref string like `<user>/<repo>[/<ref>]`

- A publicly accessible URL of an archive (eg zip or tar) file


Here’s the basic recipe for working with remotely-sourced zoo models:

## Creating remotely-sourced models [¶](\#creating-remotely-sourced-models "Permalink to this headline")

A remote source of models is defined by a directory with the following contents:

```python
manifest.json
__init__.py
    def download_model(model_name, model_path):
        pass

    def load_model(model_name, model_path, **kwargs):
        pass

```

Each component is described in detail below.

Note

By convention, model sources also contain an optional `README.md` file that
provides additional information about the models that it contains and
example syntaxes for downloading and working with them.

### manifest.json [¶](\#manifest-json "Permalink to this headline")

The remote source’s `manifest.json` file defines relevant metadata about the
model(s) that it contains:

| Field | Required? | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| --- | --- |----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `base_name` | **yes** | The base name of the model (no version info)                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `base_filename` |  | The base filename or directory of the model (no version info), if applicable.<br>This is required in order for<br>[`list_downloaded_zoo_models()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.list_downloaded_zoo_models "fiftyone.zoo.models.list_downloaded_zoo_models")<br>to detect the model and [`delete_zoo_model()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.delete_zoo_model "fiftyone.zoo.models.delete_zoo_model")<br>to delete the local copy if it is downloaded |
| `author` |  | The author of the model                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `version` |  | The version of the model (if applicable).<br>If a version is provided, then users can refer to a specific version of the model by<br>appending `@<ver>` to its name when using methods like<br>[`load_zoo_model()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.load_zoo_model "fiftyone.zoo.models.load_zoo_model"), otherwise the latest<br>version of the model is loaded by default                                                                                                       |
| `url` |  | The URL at which the model is hosted                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `license` |  | The license under which the model is distributed                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `source` |  | The original source of the model                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `description` |  | A brief description of the model                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `tags` |  | A list of tags for the model. Useful in conjunction with<br>[`list_zoo_models()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.list_zoo_models "fiftyone.zoo.models.list_zoo_models")                                                                                                                                                                                                                                                                                                          |
| `size_bytes` |  | The size of the model on disk                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `date_added` |  | The time that the model was added to the source                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `requirements` |  | JSON description of the model’s package/runtime requirements                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `manager` |  | A [`fiftyone.core.models.ModelManagerConfig`](../../api/fiftyone.core.models.ModelManagerConfig.html "fiftyone.core.models.ModelManagerConfig") dict that describes the remote<br>location of the model and how to download it. If this is not provided, then a<br>[download\_model()](#model-zoo-remote-download-model) function must be provided                                                                                                                                                       |
| `default_deployment_config_dict` |  | A [`fiftyone.core.models.ModelConfig`](../../api/fiftyone.core.models.ModelConfig.html "fiftyone.core.models.ModelConfig") dict describing how to load the model. If<br>this is not provided, then a [load\_model()](#model-zoo-remote-load-model) function<br>must be provided                                                                                                                                                                                                                          |

It can also provide optional metadata about the remote source itself:

| Field | Required? | Description |
| --- | --- | --- |
| `name` |  | A name for the remote model source |
| `url` |  | The URL of the remote model source |

Here’s an exaxmple model manifest file that declares a single model:

```python
{
    "name": "voxel51/openai-clip",
    "url": "https://github.com/voxel51/openai-clip",
    "models": [\
        {\
            "base_name": "voxel51/clip-vit-base32-torch",\
            "base_filename": "CLIP-ViT-B-32.pt",\
            "author": "OpenAI",\
            "license": "MIT",\
            "source": "https://github.com/openai/CLIP",\
            "description": "CLIP text/image encoder from Learning Transferable Visual Models From Natural Language Supervision (https://arxiv.org/abs/2103.00020) trained on 400M text-image pairs",\
            "tags": [\
                "classification",\
                "logits",\
                "embeddings",\
                "torch",\
                "clip",\
                "zero-shot"\
            ],\
            "size_bytes": 353976522,\
            "date_added": "2022-04-12 17:49:51",\
            "requirements": {\
                "packages": ["torch", "torchvision"],\
                "cpu": {\
                    "support": true\
                },\
                "gpu": {\
                    "support": true\
                }\
            }\
        }\
    ]
}

```

### Download model [¶](\#download-model "Permalink to this headline")

If a remote source contains model(s) that don’t use the `manager` key in its
[manifest](#model-zoo-remote-manifest), then it must contain an
`__init__.py` file that defines a `download_model()` method with the
signature below:

```python
def download_model(model_name, model_path):
    """Downloads the model.

    Args:
        model_name: the name of the model to download, as declared by the
            ``base_name`` and optional ``version`` fields of the manifest
        model_path: the absolute filename or directory to which to download the
            model, as declared by the ``base_filename`` field of the manifest
    """

    # Determine where to download `model_name` from
    url = ...

    # Download `url` to `model_path`
    ...

```

This method is called under-the-hood when a user calls
[`download_zoo_model()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.download_zoo_model "fiftyone.zoo.models.download_zoo_model") or
[`load_zoo_model()`](../../api/fiftyone.zoo.models.html#fiftyone.zoo.models.load_zoo_model "fiftyone.zoo.models.load_zoo_model"), and its job is
to download any relevant files from the web and organize and/or prepare
them as necessary at the provided path.

### Load model [¶](\#load-model "Permalink to this headline")

If a remote source contains model(s) that don’t use the
`default_deployment_config_dict` key in its
[manifest](#model-zoo-remote-manifest), then it must contain an
`__init__.py` file that defines a `load_model()` method with the signature
below:

```python
def load_model(model_name, model_path, **kwargs):
    """Loads the model.

    Args:
        model_name: the name of the model to load, as declared by the
            ``base_name`` and optional ``version`` fields of the manifest
        model_path: the absolute filename or directory to which the model was
            donwloaded, as declared by the ``base_filename`` field of the
            manifest
        **kwargs: optional keyword arguments that configure how the model
            is loaded

    Returns:
        a :class:`fiftyone.core.models.Model`
    """

    # The directory containing this file
    model_dir = os.path.dirname(model_path)

    # Consturct the specified `Model` instance, generally by importing
    # other modules in `model_dir`
    model = ...

    return model

```

This method’s job is to load the [`Model`](../../api/fiftyone.core.models.Model.html "fiftyone.core.models.Model") instance for the specified model whose
associated weights are stored at the provided path.

Note

Refer to [this page](design.md#model-zoo-design-overview) for more information
about wrapping models in the [`Model`](../../api/fiftyone.core.models.Model.html "fiftyone.core.models.Model") interface.

Remotely-sourced models can optionally support customized loading by accepting
optional keyword arguments to their `load_model()` method.

When
[`load_zoo_model(name_or_url, ..., **kwargs)`](../../api/fiftyone.zoo.models.html#load_zoo_model "fiftyone.zoo.models.load_zoo_model")
is called, any `kwargs` are passed through to `load_model(..., **kwargs)`.

Note

Check out [voxel51/openai-clip](https://github.com/voxel51/openai-clip)
for an example of a remote model source.

