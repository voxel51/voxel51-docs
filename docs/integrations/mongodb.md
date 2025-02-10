# MongoDB Vector Search Integration [¶](\#mongodb-vector-search-integration "Permalink to this headline")

[MongoDB](https://www.mongodb.com) is the leading open source database for
unstructured data, and we’ve made it easy to use MongoDB Atlas’
[vector search capabilities](https://www.mongodb.com/products/platform/atlas-vector-search)
on your computer vision data directly from FiftyOne!

Follow these [simple instructions](#mongodb-setup) to configure a MongoDB
Atlas cluster and get started using MongoDB Atlas + FiftyOne.

FiftyOne provides an API to create MongoDB Atlas vector search indexes, upload
vectors, and run similarity queries, both
[programmatically](#mongodb-query) in Python and via point-and-click in
the App.

Note

Did you know? You can
[search by natural language](../fiftyone_concepts/brain.md#brain-similarity-text) using MongoDB
similarity indexes!

![image-similarity](../_images/brain-image-similarity.webp)

## Basic recipe [¶](\#basic-recipe "Permalink to this headline")

The basic workflow to use MongoDB Atlas to create a similarity index on your
FiftyOne datasets and use this to query your data is as follows:

1. Configure a MongoDB Atlas cluster

2. Load a [dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) into FiftyOne

3. Compute embedding vectors for samples or patches in your dataset, or select
a model to use to generate embeddings

4. Use the `compute_similarity()`
method to generate a MongoDB similarity index for the samples or object
patches in a dataset by setting the parameter `backend="mongodb"` and
specifying a `brain_key` of your choice

5. Use this MongoDB similarity index to query your data with
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")

6. If desired, delete the index


The example below demonstrates this workflow.

Note

You must [configure](#mongodb-setup) a MongoDB Atlas 7.0 or later
cluster and provide its
[connection string](../fiftyone_concepts/config.md#configuring-mongodb-connection) to run this
example:

```python
export FIFTYONE_DATABASE_NAME=fiftyone
export FIFTYONE_DATABASE_URI='mongodb+srv://$USERNAME:$PASSWORD@fiftyone.XXXXXX.mongodb.net/?retryWrites=true&w=majority'

```

First let’s load a dataset into FiftyOne and compute embeddings for the samples:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

# Step 1: Load your data into FiftyOne
dataset = foz.load_zoo_dataset("quickstart")

# Steps 2 and 3: Compute embeddings and create a similarity index
mongodb_index = fob.compute_similarity(
    dataset,
    embeddings="embeddings",  # the field in which to store the embeddings
    brain_key="mongodb_index",
    backend="mongodb",
)

```

Once the similarity index has been generated, we can query our data in FiftyOne
by specifying the `brain_key`:

```python
# Wait for the index to be ready for querying...
assert mongodb_index.ready

# Step 4: Query your data
query = dataset.first().id  # query by sample ID
view = dataset.sort_by_similarity(
    query,
    brain_key="mongodb_index",
    k=10,  # limit to 10 most similar samples
)

# Step 5 (optional): Cleanup

# Delete the MongoDB vector search index
mongodb_index.cleanup()

# Delete run record from FiftyOne
dataset.delete_brain_run("mongodb_index")

```

Note

Skip to [this section](#mongodb-examples) for a variety of common
MongoDB query patterns.

## Setup [¶](\#setup "Permalink to this headline")

In order to use MongoDB vector search, you must connect your FiftyOne
installation to MongoDB Atlas, which you can do by navigating to
[https://cloud.mongodb.com](https://cloud.mongodb.com), creating an account,
and following the instructions there to configure your cluster.

Note

You must be running MongoDB Atlas 7.0 or later in order to programmatically
create vector search indexes
( [source](https://www.mongodb.com/docs/manual/release-notes/7.0/#atlas-search-index-management)).

As of this writing, Atlas’ shared tier (M0, M2, M5) is running MongoDB 6. In order
to use MongoDB 7, you must upgrade to an M10 cluster, which starts at $0.08/hour.

### Configuring your connection string [¶](\#configuring-your-connection-string "Permalink to this headline")

You can connect FiftyOne to your MongoDB Atlas cluster by simply providing its
[connection string](../fiftyone_concepts/config.md#configuring-mongodb-connection):

```python
export FIFTYONE_DATABASE_NAME=fiftyone
export FIFTYONE_DATABASE_URI='mongodb+srv://$USERNAME:$PASSWORD@fiftyone.XXXXXX.mongodb.net/?retryWrites=true&w=majority'

```

### Using the MongoDB backend [¶](\#using-the-mongodb-backend "Permalink to this headline")

By default, calling
`compute_similarity()` or
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
will use an sklearn backend.

To use the MongoDB backend, simply set the optional `backend` parameter of
`compute_similarity()` to
`"mongodb"`:

```python
import fiftyone.brain as fob

fob.compute_similarity(..., backend="mongodb", ...)

```

Alternatively, you can permanently configure FiftyOne to use the MonogDB
backend by setting the following environment variable:

```python
export FIFTYONE_BRAIN_DEFAULT_SIMILARITY_BACKEND=mongodb

```

or by setting the `default_similarity_backend` parameter of your
[brain config](../fiftyone_concepts/brain.md#brain-config) located at `~/.fiftyone/brain_config.json`:

```python
{
    "default_similarity_backend": "mongodb"
}

```

### MongoDB config parameters [¶](\#mongodb-config-parameters "Permalink to this headline")

The MongoDB backend supports a variety of query parameters that can be used to
customize your similarity queries. These parameters include:

- **index\_name** ( _None_): the name of the MongoDB vector search index to use
or create. If not specified, a new unique name is generated automatically

- **metric** ( _“cosine”_): the distance/similarity metric to use when
creating a new index. The supported values are
`("cosine", "dotproduct", "euclidean")`


For detailed information on these parameters, see the
[MongoDB documentation](https://www.mongodb.com/docs/atlas/atlas-search/field-types/knn-vector).

You can specify these parameters via any of the strategies described in the
previous section. Here’s an example of a [brain config](../fiftyone_concepts/brain.md#brain-config)
that includes all of the available parameters:

```python
{
    "similarity_backends": {
        "mongodb": {
            "index_name": "your-index",
            "metric": "cosine"
        }
    }
}

```

However, typically these parameters are directly passed to
`compute_similarity()` to configure
a specific new index:

```python
mongodb_index = fob.compute_similarity(
    ...
    backend="mongodb",
    brain_key="mongodb_index",
    index_name="your-index",
    metric="cosine",
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
will not delete any associated MongoDB vector search index, which you can
do as follows:

```python
# Delete the MongoDB vector search index
mongodb_index = dataset.load_brain_results(brain_key)
mongodb_index.cleanup()

```

## Examples [¶](\#examples "Permalink to this headline")

This section demonstrates how to perform some common vector search workflows on
a FiftyOne dataset using the MongoDB backend.

Note

All of the examples below assume you have configured your MongoDB Atlas
cluster as described in [this section](#mongodb-setup).

### Create a similarity index [¶](\#create-a-similarity-index "Permalink to this headline")

In order to create a new MongoDB similarity index, you need to specify either
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
brain_key = "mongodb_index"

# Option 1: Compute embeddings on the fly from model name
fob.compute_similarity(
    dataset,
    model=model_name,
    embeddings="embeddings",  # the field in which to store the embeddings
    backend="mongodb",
    brain_key=brain_key,
)

# Option 2: Compute embeddings on the fly from model instance
fob.compute_similarity(
    dataset,
    model=model,
    embeddings="embeddings",  # the field in which to store the embeddings
    backend="mongodb",
    brain_key=brain_key,
)

# Option 3: Pass precomputed embeddings as a numpy array
embeddings = dataset.compute_embeddings(model)
fob.compute_similarity(
    dataset,
    embeddings=embeddings,
    embeddings_field="embeddings",  # the field in which to store the embeddings
    backend="mongodb",
    brain_key=brain_key,
)

# Option 4: Pass precomputed embeddings by field name
# Note that MongoDB vector indexes require list fields
embeddings = dataset.compute_embeddings(model)
dataset.set_values("embeddings", embeddings.tolist())
fob.compute_similarity(
    dataset,
    embeddings="embeddings",  # the field that contains the embeddings
    backend="mongodb",
    brain_key=brain_key,
)

```

Note

You can customize the MongoDB index by passing any
[supported parameters](#mongodb-config-parameters) as extra kwargs.

### Create a patch similarity index [¶](\#create-a-patch-similarity-index "Permalink to this headline")

Warning

The MongoDB backend does not yet support indexing object patches, so the
code below will not yet run. Check back soon!

You can also create a similarity index for
[object patches](../fiftyone_concepts/brain.md#brain-object-similarity) within your dataset by
including the `patches_field` argument to
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
    embeddings="embeddings",  # the attribute in which to store the embeddings
    backend="mongodb",
    brain_key="mongodb_patches",
)

```

Note

You can customize the MongoDB index by passing any
[supported parameters](#mongodb-config-parameters) as extra kwargs.

### Connect to an existing index [¶](\#connect-to-an-existing-index "Permalink to this headline")

If you have already created a MongoDB index storing the embedding vectors
for the samples or patches in your dataset, you can connect to it by passing
the `index_name` to
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
    index_name="your-index",            # the existing MongoDB index
    brain_key="mongodb_index",
    backend="mongodb",
)

```

### Add/remove embeddings from an index [¶](\#add-remove-embeddings-from-an-index "Permalink to this headline")

You can use
`add_to_index()`
and
`remove_from_index()`
to add and remove embeddings from an existing Mongodb index.

These methods can come in handy if you modify your FiftyOne dataset and need
to update the Mongodb index to reflect these changes:

```python
import numpy as np

import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

mongodb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    embeddings="embeddings",  # the field in which to store the embeddings
    brain_key="mongodb_index",
    backend="mongodb",
)
print(mongodb_index.total_index_size)  # 200

view = dataset.take(10)
ids = view.values("id")

# Delete 10 samples from a dataset
dataset.delete_samples(view)

# Delete the corresponding vectors from the index
mongodb_index.remove_from_index(sample_ids=ids)

# Add 20 samples to a dataset
samples = [fo.Sample(filepath="tmp%d.jpg" % i) for i in range(20)]
sample_ids = dataset.add_samples(samples)

# Add corresponding embeddings to the index
embeddings = np.random.rand(20, 512)
mongodb_index.add_to_index(embeddings, sample_ids)

print(mongodb_index.total_index_size)  # 210

```

### Retrieve embeddings from an index [¶](\#retrieve-embeddings-from-an-index "Permalink to this headline")

You can use
`get_embeddings()`
to retrieve embeddings from a Mongodb index by ID:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

mongodb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    embeddings="embeddings",  # the field in which to store the embeddings
    brain_key="mongodb_index",
    backend="mongodb",
)

# Retrieve embeddings for the entire dataset
ids = dataset.values("id")
embeddings, sample_ids, _ = mongodb_index.get_embeddings(sample_ids=ids)
print(embeddings.shape)  # (200, 512)
print(sample_ids.shape)  # (200,)

# Retrieve embeddings for a view
ids = dataset.take(10).values("id")
embeddings, sample_ids, _ = mongodb_index.get_embeddings(sample_ids=ids)
print(embeddings.shape)  # (10, 512)
print(sample_ids.shape)  # (10,)

```

### Querying a MongoDB index [¶](\#querying-a-mongodb-index "Permalink to this headline")

You can query a MongoDB index by appending a
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

mongodb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    embeddings="embeddings",  # the field in which to store the embeddings
    brain_key="mongodb_index",
    backend="mongodb",
)

# Wait for the index to be ready for querying...
assert mongodb_index.ready

# Query by vector
query = np.random.rand(512)  # matches the dimension of CLIP embeddings
view = dataset.sort_by_similarity(query, k=10, brain_key="mongodb_index")

# Query by sample ID
query = dataset.first().id
view = dataset.sort_by_similarity(query, k=10, brain_key="mongodb_index")

# Query by a list of IDs
query = [dataset.first().id, dataset.last().id]
view = dataset.sort_by_similarity(query, k=10, brain_key="mongodb_index")

# Query by text prompt
query = "a photo of a dog"
view = dataset.sort_by_similarity(query, k=10, brain_key="mongodb_index")

```

Note

Performing a similarity search on a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") will **only** return
results from the view; if the view contains samples that were not included
in the index, they will never be included in the result.

This means that you can index an entire [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") once and then perform
searches on subsets of the dataset by
[constructing views](../fiftyone_concepts/using_views.md#using-views) that contain the images of
interest.

Note

Currently, when performing a similarity search on a view with the MongoDB backend,
the full index is queried and the resulting samples are restricted to the desired view.
This may result in fewer samples than requested being returned by the search.

### Checking if an index is ready [¶](\#checking-if-an-index-is-ready "Permalink to this headline")

You can use the `ready` property of a MongoDB index to check whether a newly
created vector search index is ready for querying:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

mongodb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    embeddings="embeddings",  # the field in which to store the embeddings
    brain_key="mongodb_index",
    backend="mongodb",
)

# Wait for the index to be ready for querying...
assert mongodb_index.ready

```

### Advanced usage [¶](\#advanced-usage "Permalink to this headline")

As [previously mentioned](#mongodb-config-parameters), you can customize
your MongoDB index by providing optional parameters to
`compute_similarity()`.

Here’s an example of creating a similarity index backed by a customized MongoDB
index. Just for fun, we’ll specify a custom index name, use dot product
similarity, and populate the index for only a subset of our dataset:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# Create a custom MongoDB index
mongodb_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    embeddings_field="embeddings",  # the field in which to store the embeddings
    embeddings=False,               # add embeddings later
    brain_key="mongodb_index",
    backend="mongodb",
    index_name="custom-quickstart-index",
    metric="dotproduct",
)

# Add embeddings for a subset of the dataset
view = dataset[:20]
embeddings, sample_ids, _ = mongodb_index.compute_embeddings(view)
mongodb_index.add_to_index(embeddings, sample_ids)

print(mongodb_index.total_index_size)  # 20
print(mongodb_index.config.index_name)  # custom-quickstart-index
print(mongodb_index.config.metric)  # dotproduct

```

