# Remotely-Sourced Zoo Datasets [¶](\#remotely-sourced-zoo-datasets "Permalink to this headline")

This page describes how to work with and create zoo datasets whose
download/preparation methods are hosted via GitHub repositories or public URLs.

Note

To download from a private GitHub repository that you have access to,
provide your GitHub personal access token by setting the `GITHUB_TOKEN`
environment variable.

## Working with remotely-sourced datasets [¶](\#working-with-remotely-sourced-datasets "Permalink to this headline")

Working with remotely-sourced zoo datasets is just like
[built-in zoo datasets](datasets.md#dataset-zoo-datasets), as both varieties support
the [full zoo API](api.md#dataset-zoo-api).

When specifying remote sources, you can provide any of the following:

- A GitHub repo URL like `https://github.com/<user>/<repo>`

- A GitHub ref like `https://github.com/<user>/<repo>/tree/<branch>` or
`https://github.com/<user>/<repo>/commit/<commit>`

- A GitHub ref string like `<user>/<repo>[/<ref>]`

- A publicly accessible URL of an archive (eg zip or tar) file


Here’s the basic recipe for working with remotely-sourced zoo datasets:

## Creating remotely-sourced datasets [¶](\#creating-remotely-sourced-datasets "Permalink to this headline")

A remotely-sourced dataset is defined by a directory with the following
contents:

```python
fiftyone.yml
__init__.py
    def download_and_prepare(dataset_dir, split=None, **kwargs):
        pass

    def load_dataset(dataset, dataset_dir, split=None, **kwargs):
        pass

```

Each component is described in detail below.

Note

By convention, datasets also contain an optional `README.md` file that
provides additional information about the dataset and example syntaxes for
downloading and working with it.

### fiftyone.yml [¶](\#fiftyone-yml "Permalink to this headline")

The dataset’s `fiftyone.yml` or `fiftyone.yaml` file defines relevant metadata
about the dataset:

| Field | Required? | Description |
| --- | --- | --- |
| `name` | **yes** | The name of the dataset. Once you’ve downloaded all or part of a<br>remotely-sourced zoo dataset, it will subsequently appear as an available<br>zoo dataset under this name when using the<br>[zoo API](api.md#dataset-zoo-api) |
| `type` |  | Declare that the directory defines a `dataset`. This can be omitted for<br>backwards compatibility, but it is recommended to specify this |
| `author` |  | The author of the dataset |
| `version` |  | The version of the dataset |
| `url` |  | The source (eg GitHub repository) where the directory containing this file<br>is hosted |
| `source` |  | The original source of the dataset |
| `license` |  | The license under which the dataset is distributed |
| `description` |  | A brief description of the dataset |
| `fiftyone.version` |  | A semver version specifier (or `*`) describing the required<br>FiftyOne version for the dataset to load properly |
| `supports_partial_downloads` |  | Specify `true` or `false` whether parts of the dataset can be<br>downloaded/loaded by providing `kwargs` to<br>[`download_zoo_dataset()`](../../api/fiftyone.zoo.datasets.html#download_zoo_dataset "fiftyone.zoo.datasets.download_zoo_dataset")<br>or [`load_zoo_dataset()`](../../api/fiftyone.zoo.datasets.html#load_zoo_dataset "fiftyone.zoo.datasets.load_zoo_dataset") as<br>[described here](#dataset-zoo-remote-partial-downloads). If omitted,<br>this is assumed to be `false` |
| `tags` |  | A list of tags for the dataset. Useful in conjunction with<br>[`list_zoo_datasets()`](../../api/fiftyone.zoo.datasets.html#list_zoo_datasets "fiftyone.zoo.datasets.list_zoo_datasets") |
| `splits` |  | A list of the dataset’s supported splits. This should be omitted if the<br>dataset does not contain splits |
| `size_samples` |  | The totaal number of samples in the dataset, or a list of per-split sizes |

Here are two example dataset YAML files:

### Download and prepare [¶](\#download-and-prepare "Permalink to this headline")

All dataset’s `__init__.py` files must define a `download_and_prepare()`
method with the signature below:

```python
def download_and_prepare(dataset_dir, split=None, **kwargs):
    """Downloads the dataset and prepares it for loading into FiftyOne.

    Args:
        dataset_dir: the directory in which to construct the dataset
        split (None): a specific split to download, if the dataset supports
            splits. The supported split values are defined by the dataset's
            YAML file
        **kwargs: optional keyword arguments that your dataset can define to
            configure what/how the download is performed

    Returns:
        a tuple of

        -   ``dataset_type``: a ``fiftyone.types.Dataset`` type that the
            dataset is stored in locally, or None if the dataset provides
            its own ``load_dataset()`` method
        -   ``num_samples``: the total number of downloaded samples for the
            dataset or split
        -   ``classes``: a list of classes in the dataset, or None if not
            applicable
    """

    # Download files and organize them in `dataset_dir`
    ...

    # Define how the data is stored
    dataset_type = fo.types.ImageClassificationDirectoryTree
    dataset_type = None  # custom ``load_dataset()`` method

    # Indicate how many samples have been downloaded
    # May be less than the total size if partial downloads have been used
    num_samples = 10000

    # Optionally report what classes exist in the dataset
    classes = None
    classes = ["cat", "dog", ...]

    return dataset_type, num_samples, classes

```

This method is called under-the-hood when a user calls
[`download_zoo_dataset()`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.download_zoo_dataset "fiftyone.zoo.datasets.download_zoo_dataset") or
[`load_zoo_dataset()`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.load_zoo_dataset "fiftyone.zoo.datasets.load_zoo_dataset"), and its
job is to download any relevant files from the web and organize and/or prepare
them as necessary into a format that’s ready to be loaded into a FiftyOne
dataset.

The `dataset_type` that `download_and_prepare()` returns defines how it the
dataset is ultimately loaded into FiftyOne:

- **Built-in importer**: in many cases, FiftyOne already contains a
[built-in importer](../../../fiftyone_concepts/dataset_creation/datasets/#supported-formats) that can be leveraged
to load data on disk into FiftyOne. Remotely-sourced datasets can take
advantage of this by simply returning the appropriate `dataset_type` from
`download_and_prepare()`, which is then used to load the data as follows:


```python
# If the dataset has splits, `dataset_dir` will be the split directory
dataset_importer_cls = dataset_type.get_dataset_importer_cls()
dataset_importer = dataset_importer_cls(dataset_dir=dataset_dir, **kwargs)

dataset.add_importer(dataset_importer, **kwargs)

```

- **Custom loader**: if `dataset_type=None` is returned, then
`__init__.py` must also contain a `load_dataset()` method as described
below that handles loading the data into FiftyOne as follows:


```python
load_dataset(dataset, dataset_dir, **kwargs)

```

### Load dataset [¶](\#load-dataset "Permalink to this headline")

Datasets that don’t use a built-in importer must also define a
`load_dataset()` method in their `__init__.py` with the signature below:

```python
def load_dataset(dataset, dataset_dir, split=None, **kwargs):
    """Loads the dataset into the given FiftyOne dataset.

    Args:
        dataset: a :class:`fiftyone.core.dataset.Dataset` to which to import
        dataset_dir: the directory to which the dataset was downloaded
        split (None): a split to load. The supported values are
            ``("train", "validation", "test")``
        **kwargs: optional keyword arguments that your dataset can define to
            configure what/how the load is performed
    """

    # Load data into samples
    samples = [...]

    # Add samples to the dataset
    dataset.add_samples(samples)

```

This method’s job is to load the filepaths and any relevant labels into
[`Sample`](../../api/fiftyone.core.sample.Sample.html "fiftyone.core.sample.Sample") objects and then call
[`add_samples()`](../../api/fiftyone.core.dataset.Dataset.html#add_samples "fiftyone.core.dataset.Dataset.add_samples") or a similar
method to add them to the provided [`Dataset`](../../api/fiftyone.core.dataset.Dataset.html "fiftyone.core.dataset.Dataset").

## Partial downloads [¶](\#partial-downloads "Permalink to this headline")

Remotely-sourced datasets can support partial downloads, which is useful for a
variety of reasons, including:

- A dataset may contain labels for multiple task types but the user is only
interested in a subset of them

- The dataset may be very large and the user only wants to download a small
subset of the samples to get familiar with the dataset


Datasets that support partial downloads should declare this in their
[fiftyone.yml](#zoo-dataset-remote-fiftyone-yml):

```python
supports_partial_downloads: true

```

The partial download behavior itself is defined via `**kwargs` in the
dataset’s `__init__.py` methods:

```python
def download_and_prepare(dataset_dir, split=None, **kwargs):
    pass

def load_dataset(dataset, dataset_dir, split=None, **kwargs):
    pass

```

When
[`download_zoo_dataset(url, ..., **kwargs)`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.download_zoo_dataset "fiftyone.zoo.datasets.download_zoo_dataset")
is called, any `kwargs` declared by `download_and_prepare()` are passed
through to it.

When
[`load_zoo_dataset(name_or_url, ..., **kwargs)`](../../api/fiftyone.zoo.datasets.html#fiftyone.zoo.datasets.load_zoo_dataset "fiftyone.zoo.datasets.load_zoo_dataset")
is called, any `kwargs` declared by `download_and_prepare()` and
`load_dataset()` are passed through to them, respectively.

Note

Check out [voxel51/coco-2017](https://github.com/voxel51/coco-2017) for
an example of a remotely-sourced dataset that supports partial downloads.

