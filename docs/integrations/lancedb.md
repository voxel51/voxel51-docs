# LanceDB Integration [¶](\#lancedb-integration "Permalink to this headline")

[LanceDB](https://www.lancedb.com) is a serverless vector database with deep
integrations with the Python ecosystem. It requires no setup and is free to
use.

FiftyOne provides an API to create LanceDB tables and run
similarity queries, both [programmatically](#lancedb-query) in Python and
via point-and-click in the App.

## Basic recipe [¶](\#basic-recipe "Permalink to this headline")

The basic workflow to use LanceDB to create a similarity index on your FiftyOne
datasets and use this to query your data is as follows:

1. Load a [dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) into FiftyOne

2. Compute embedding vectors for samples or patches in your dataset, or select
a model to use to generate embeddings

3. Use the `compute_similarity()`
method to generate a LanceDB table for the samples or object
patches embeddings in a dataset by setting the parameter `backend="lancedb"` and
specifying a `brain_key` of your choice

4. Use this LanceDB table to query your data with
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")

5. If desired, delete the table

The example below demonstrates this workflow.

Note

You must install the
[LanceDB Python client](https://github.com/lancedb/lancedb) to run this
example:

```python
pip install lancedb

```

Note that, if you are using a custom LanceDB URI, you can store your
credentials as described in [this section](#lancedb-setup) to avoid
entering them manually each time you interact with your LanceDB index.

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

# Step 1: Load your data into FiftyOne
dataset = foz.load_zoo_dataset("quickstart")

# Steps 2 and 3: Compute embeddings and create a similarity index
lancedb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="lancedb_index",
    backend="lancedb",
)

```

Once the similarity index has been generated, we can query our data in FiftyOne
by specifying the `brain_key`:

```python
# Step 4: Query your data
query = dataset.first().id  # query by sample ID
view = dataset.sort_by_similarity(
    query,
    brain_key="lancedb_index",
    k=10,  # limit to 10 most similar samples
)

# Step 5 (optional): Cleanup

# Delete the LanceDB table
lancedb_index.cleanup()

# Delete run record from FiftyOne
dataset.delete_brain_run("lancedb_index")

```

## Setup [¶](\#setup "Permalink to this headline")

You can get started using LanceDB by simply installing the
[LanceDB Python client](https://github.com/lancedb/lancedb):

```python
pip install lancedb

```

### Using the LanceDB backend [¶](\#using-the-lancedb-backend "Permalink to this headline")

By default, calling
`compute_similarity()` or
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
will use an sklearn backend.

To use the LanceDB backend, simply set the optional `backend` parameter of
`compute_similarity()` to
`"lancedb"`:

```python
import fiftyone.brain as fob

fob.compute_similarity(..., backend="lancedb", ...)

```

Alternatively, you can permanently configure FiftyOne to use the LanceDB
backend by setting the following environment variable:

```python
export FIFTYONE_BRAIN_DEFAULT_SIMILARITY_BACKEND=lancedb

```

or by setting the `default_similarity_backend` parameter of your
[brain config](../fiftyone_concepts/brain.md#brain-config) located at `~/.fiftyone/brain_config.json`:

```python
{
    "default_similarity_backend": "lancedb"
}

```

### LanceDB config parameters [¶](\#lancedb-config-parameters "Permalink to this headline")

The LanceDB backend supports query parameters that can be used to customize
your similarity queries. These parameters include:

- **table\_name** ( _None_): the name of the LanceDB table to use. If none is
provided, a new table will be created

- **metric** ( _“cosine”_): the embedding distance metric to use when creating
a new table. The supported values are `("cosine", "euclidean")`

- **uri** ( _“/tmp/lancedb”_): the database URI to use

You can specify these parameters via any of the strategies described in the
previous section. Here’s an example of a [brain config](../fiftyone_concepts/brain.md#brain-config)
that includes all of the available parameters:

```python
{
    "similarity_backends": {
        "lancedb": {
            "table_name": "your-table",
            "metric": "euclidean",
            "uri": "/tmp/lancedb"
        }
    }
}

```

However, typically these parameters are directly passed to
`compute_similarity()` to configure
a specific new index:

```python
lancedb_index = fob.compute_similarity(
    ...
    backend="lancedb",
    brain_key="lancedb_index",
    table_name="your-table",
    metric="euclidean",
    uri="/tmp/lancedb",
)

```

## Managing brain runs [¶](\#managing-brain-runs "Permalink to this headline")

FiftyOne provides a variety of methods that you can use to manage brain runs.

For example, you can call
[`list_brain_runs()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.list_brain_runs "fiftyone.core.collections.SampleCollection.list_brain_runs")
to see the available brain keys on a dataset:

```python
import fiftyone.brain as fob

# List all brain runs
dataset.list_brain_runs()

# Only list similarity runs
dataset.list_brain_runs(type=fob.Similarity)

# Only list specific similarity runs
dataset.list_brain_runs(
    type=fob.Similarity,
    patches_field="ground_truth",
    supports_prompts=True,
)

```

Or, you can use
[`get_brain_info()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.get_brain_info "fiftyone.core.collections.SampleCollection.get_brain_info")
to retrieve information about the configuration of a brain run:

```python
info = dataset.get_brain_info(brain_key)
print(info)

```

Use [`load_brain_results()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_brain_results "fiftyone.core.collections.SampleCollection.load_brain_results")
to load the `SimilarityIndex` instance for a brain run.

You can use
[`rename_brain_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.rename_brain_run "fiftyone.core.collections.SampleCollection.rename_brain_run")
to rename the brain key associated with an existing similarity results run:

```python
dataset.rename_brain_run(brain_key, new_brain_key)

```

Finally, you can use
[`delete_brain_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.delete_brain_run "fiftyone.core.collections.SampleCollection.delete_brain_run")
to delete the record of a similarity index computation from your FiftyOne
dataset:

```python
dataset.delete_brain_run(brain_key)

```

Note

Calling
[`delete_brain_run()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.delete_brain_run "fiftyone.core.collections.SampleCollection.delete_brain_run")
only deletes the **record** of the brain run from your FiftyOne dataset; it
will not delete any associated LanceDB table, which you can do as follows:

```python
# Delete the LanceDB table
lancedb_index = dataset.load_brain_results(brain_key)
lancedb_index.cleanup()

```

## Examples [¶](\#examples "Permalink to this headline")

This section demonstrates how to perform some common vector search workflows on
a FiftyOne dataset using the LanceDB backend.

### Create a similarity index [¶](\#create-a-similarity-index "Permalink to this headline")

In order to create a new LanceDB similarity index, you need to specify either
the `embeddings` or `model` argument to
`compute_similarity()`. Here’s a few
possibilities:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")
model_name = "clip-vit-base32-torch"
model = foz.load_zoo_model(model_name)
brain_key = "lancedb_index"

# Option 1: Compute embeddings on the fly from model name
fob.compute_similarity(
    dataset,
    model=model_name,
    backend="lancedb",
    brain_key=brain_key,
)

# Option 2: Compute embeddings on the fly from model instance
fob.compute_similarity(
    dataset,
    model=model,
    backend="lancedb",
    brain_key=brain_key,
)

# Option 3: Pass precomputed embeddings as a numpy array
embeddings = dataset.compute_embeddings(model)
fob.compute_similarity(
    dataset,
    embeddings=embeddings,
    backend="lancedb",
    brain_key=brain_key,
)

# Option 4: Pass precomputed embeddings by field name
dataset.compute_embeddings(model, embeddings_field="embeddings")
fob.compute_similarity(
    dataset,
    embeddings="embeddings",
    backend="lancedb",
    brain_key=brain_key,
)

```

Note

You can customize the LanceDB index by passing any
[supported parameters](#lancedb-config-parameters) as extra kwargs.

### Create a patch similarity index [¶](\#create-a-patch-similarity-index "Permalink to this headline")

You can also create a similarity index for
[object patches](../fiftyone_concepts/brain.md#brain-object-similarity) within your dataset by
specifying a `patches_field` argument to
`compute_similarity()`:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

fob.compute_similarity(
    dataset,
    patches_field="ground_truth",
    model="clip-vit-base32-torch",
    backend="lancedb",
    brain_key="lancedb_index",
)

```

Note

You can customize the LanceDB index by passing any
[supported parameters](#lancedb-config-parameters) as extra kwargs.

### Connect to an existing index [¶](\#connect-to-an-existing-index "Permalink to this headline")

If you have already created a LanceDB table storing the embedding vectors for
the samples or patches in your dataset, you can connect to it by passing the
`table_name` to
`compute_similarity()`:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",      # zoo model used (if applicable)
    embeddings=False,                   # don't compute embeddings
    table_name="your-table",            # the existing LanceDB table
    brain_key="lancedb_index",
    backend="lancedb",
)

```

### Add/remove embeddings from an index [¶](\#add-remove-embeddings-from-an-index "Permalink to this headline")

You can use
`add_to_index()`
and
`remove_from_index()`
to add and remove embeddings from an existing Lancedb index.

These methods can come in handy if you modify your FiftyOne dataset and need
to update the LanceDB index to reflect these changes:

```python
import numpy as np

import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

lancedb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="lancedb_index",
    backend="lancedb",
)
print(lancedb_index.total_index_size)  # 200

view = dataset.take(10)
ids = view.values("id")

# Delete 10 samples from a dataset
dataset.delete_samples(view)

# Delete the corresponding vectors from the index
lancedb_index.remove_from_index(sample_ids=ids)

# Add 20 samples to a dataset
samples = [fo.Sample(filepath="tmp%d.jpg" % i) for i in range(20)]
sample_ids = dataset.add_samples(samples)

# Add corresponding embeddings to the index
embeddings = np.random.rand(20, 512)
lancedb_index.add_to_index(embeddings, sample_ids)

print(lancedb_index.total_index_size)  # 210

```

### Retrieve embeddings from an index [¶](\#retrieve-embeddings-from-an-index "Permalink to this headline")

You can use
`get_embeddings()`
to retrieve embeddings from a LanceDB index by ID:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

lancedb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="lancedb_index",
    backend="lancedb",
)

# Retrieve embeddings for the entire dataset
ids = dataset.values("id")
embeddings, sample_ids, _ = lancedb_index.get_embeddings(sample_ids=ids)
print(embeddings.shape)  # (200, 512)
print(sample_ids.shape)  # (200,)

# Retrieve embeddings for a view
ids = dataset.take(10).values("id")
embeddings, sample_ids, _ = lancedb_index.get_embeddings(sample_ids=ids)
print(embeddings.shape)  # (10, 512)
print(sample_ids.shape)  # (10,)

```

### Querying a LanceDB index [¶](\#querying-a-lancedb-index "Permalink to this headline")

You can query a LanceDB index by appending a
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
stage to any dataset or view. The query can be any of the following:

- An ID (sample or patch)

- A query vector of same dimension as the index

- A list of IDs (samples or patches)

- A text prompt (if [supported by the model](../fiftyone_concepts/brain.md#brain-similarity-text))

```python
import numpy as np

import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="lancedb_index",
    backend="lancedb",
)

# Query by vector
query = np.random.rand(512)  # matches the dimension of CLIP embeddings
view = dataset.sort_by_similarity(query, k=10, brain_key="lancedb_index")

# Query by sample ID
query = dataset.first().id
view = dataset.sort_by_similarity(query, k=10, brain_key="lancedb_index")

# Query by a list of IDs
query = [dataset.first().id, dataset.last().id]
view = dataset.sort_by_similarity(query, k=10, brain_key="lancedb_index")

# Query by text prompt
query = "a photo of a dog"
view = dataset.sort_by_similarity(query, k=10, brain_key="lancedb_index")

```

Note

Performing a similarity search on a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") will **only** return
results from the view; if the view contains samples that were not included
in the index, they will never be included in the result.

This means that you can index an entire [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") once and then perform
searches on subsets of the dataset by
[constructing views](../fiftyone_concepts/using_views.md#using-views) that contain the images of
interest.

### Advanced usage [¶](\#advanced-usage "Permalink to this headline")

LanceDB is compatible with the Python ecosystem and can be used with pandas,
numpy, and arrow:

```python
lancedb_index = fob.compute_similarity(..., backend="lancedb", ...)

# Retrieve the raw LanceDB table
table = lancedb_index.table

df = table.to_pandas()  # get the table as a pandas dataframe
pa = table.to_arrow()   # get the table as an arrow table

```
