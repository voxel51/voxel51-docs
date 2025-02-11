# Pinecone Integration [¶](\#pinecone-integration "Permalink to this headline")

[Pinecone](https://www.pinecone.io) is one of the most popular vector search
engines available, and we’ve made it easy to use Pinecone’s vector search
capabilities on your computer vision data directly from FiftyOne!

Follow these [simple instructions](#pinecone-setup) to configure your
credentials and get started using Pinecone + FiftyOne.

FiftyOne provides an API to create Pinecone indexes, upload vectors, and run
similarity queries, both [programmatically](#pinecone-query) in Python and
via point-and-click in the App.

Note

Did you know? You can
[search by natural language](../fiftyone_concepts/brain.md#brain-similarity-text) using Pinecone
similarity indexes!

![object-similarity](../_images/brain-object-similarity.webp)

## Basic recipe [¶](\#basic-recipe "Permalink to this headline")

The basic workflow to use Pinecone to create a similarity index on your
FiftyOne datasets and use this to query your data is as follows:

1. Load a [dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) into FiftyOne

2. Compute embedding vectors for samples or patches in your dataset, or select
a model to use to generate embeddings

3. Use the `compute_similarity()`
methodto generate a Pinecone similarity index for the samples or object
patches in a dataset by setting the parameter `backend="pinecone"` and
specifying a `brain_key` of your choice

4. Use this Pinecone similarity index to query your data with
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")

5. If desired, delete the index

The example below demonstrates this workflow.

Note

You must create a [Pinecone account](https://www.pinecone.io/), download
a [Pinecone API key](https://app.pinecone.io/organizations), and install
the
[Pinecone Python client](https://github.com/pinecone-io/pinecone-python-client)
to run this example:

```python
pip install -U pinecone-client

```

Note that you can store your Pinecone credentials as described in
[this section](#pinecone-setup) to avoid entering them manually each
time you interact with your Pinecone index.

First let’s load a dataset into FiftyOne and compute embeddings for the
samples:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

# Step 1: Load your data into FiftyOne
dataset = foz.load_zoo_dataset("quickstart")

# Steps 2 and 3: Compute embeddings and create a similarity index
pinecone_index = fob.compute_similarity(
    dataset,
    brain_key="pinecone_index",
    backend="pinecone",
)

```

Once the similarity index has been generated, we can query our data in FiftyOne
by specifying the `brain_key`:

```python
# Step 4: Query your data
query = dataset.first().id  # query by sample ID
view = dataset.sort_by_similarity(
    query,
    brain_key=brain_key,
    k=10,  # limit to 10 most similar samples
)

# Step 5 (optional): Cleanup

# Delete the Pinecone index
pinecone_index = dataset.load_brain_results(brain_key)
pinecone_index.cleanup()

# Delete run record from FiftyOne
dataset.delete_brain_run("pinecone_index")

```

Note

Skip to [this section](#pinecone-examples) to see a variety of common
Pinecone query patterns.

## Setup [¶](\#setup "Permalink to this headline")

The easiest way to get started with Pinecone is to
[create a free Pinecone account](https://www.pinecone.io) and copy your
Pinecone API key.

### Installing the Pinecone client [¶](\#installing-the-pinecone-client "Permalink to this headline")

In order to use the Pinecone backend, you must install the
[Pinecone Python client](https://github.com/pinecone-io/pinecone-python-client):

```python
pip install pinecone-client

```

### Using the Pinecone backend [¶](\#using-the-pinecone-backend "Permalink to this headline")

By default, calling
`compute_similarity()` or
[`sort_by_similarity()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.sort_by_similarity "fiftyone.core.collections.SampleCollection.sort_by_similarity")
will use an sklearn backend.

To use the Pinecone backend, simply set the optional `backend` parameter of
`compute_similarity()` to
`"pinecone"`:

```python
import fiftyone.brain as fob

fob.compute_similarity(..., backend="pinecone", ...)

```

Alternatively, you can permanently configure FiftyOne to use the Pinecone
backend by setting the following environment variable:

```python
export FIFTYONE_BRAIN_DEFAULT_SIMILARITY_BACKEND=pinecone

```

or by setting the `default_similarity_backend` parameter of your
[brain config](../fiftyone_concepts/brain.md#brain-config) located at `~/.fiftyone/brain_config.json`:

```python
{
    "default_similarity_backend": "pinecone"
}

```

### Authentication [¶](\#authentication "Permalink to this headline")

In order to connect to a Pinecone server, you must provide your credentials,
which can be done in a variety of ways.

**Environment variables (recommended)**

The recommended way to configure your Pinecone credentials is to store them
in the environment variables shown below, which are automatically accessed by
FiftyOne whenever a connection to Pinecone is made:

```python
export FIFTYONE_BRAIN_SIMILARITY_PINECONE_API_KEY=XXXXXX

# Serverless indexes
export FIFTYONE_BRAIN_SIMILARITY_PINECONE_CLOUD="aws"
export FIFTYONE_BRAIN_SIMILARITY_PINECONE_REGION="us-east-1"

# Pod-based indexes
export FIFTYONE_BRAIN_SIMILARITY_PINECONE_ENVIRONMENT="us-east-1-aws"

```

**FiftyOne Brain config**

You can also store your credentials in your [brain config](../fiftyone_concepts/brain.md#brain-config)
located at `~/.fiftyone/brain_config.json`:

```python
{
    "similarity_backends": {
        "pinecone": {
            "api_key": "XXXXXXXXXXXX",
            "cloud": "aws",                 # serverless indexes
            "region": "us-east-1",          # serverless indexes
            "environment": "us-east-1-aws"  # pod-based indexes
        }
    }
}

```

Note that this file will not exist until you create it.

**Keyword arguments**

You can manually provide your Pinecone credentials as keyword arguments each
time you call methods like
`compute_similarity()` that require
connections to Pinecone:

```python
import fiftyone.brain as fob

pinecone_index = fob.compute_similarity(
    ...
    backend="pinecone",
    brain_key="pinecone_index",
    api_key="XXXXXX",
    cloud="aws",
    region="us-east-1",
)

```

Note that, when using this strategy, you must manually provide the credentials
when loading an index later via
[`load_brain_results()`](../api/fiftyone.core.collections.html#fiftyone.core.collections.SampleCollection.load_brain_results "fiftyone.core.collections.SampleCollection.load_brain_results"):

```python
pinecone_index = dataset.load_brain_results(
    "pinecone_index",
    api_key="XXXXXX",
    cloud="aws",
    region="us-east-1",
)

```

### Pinecone config parameters [¶](\#pinecone-config-parameters "Permalink to this headline")

The Pinecone backend supports a variety of query parameters that can be used to
customize your similarity queries. These parameters include:

- **index\_name** ( _None_): the name of the Pinecone index to use or create.
If not specified, a new unique name is generated automatically

- **index\_type** ( _None_): the index type to use when creating a new index.
The supported values are `["serverless", "pod"]`, and the default is
`"serverless"`

- **namespace** ( _None_): a namespace under which to store vectors added to
the index

- **metric** ( _“cosine”_): the distance/similarity metric to use for the
index. Supported values are `("cosine", "dotproduct", "euclidean")`

- **replicas** ( _None_): an optional number of replicas to use when creating
a new pod-based index

- **shards** ( _None_): an optional number of shards to use when creating a
new pod-based index

- **pods** ( _None_): an optional number of pods to use when creating a new
pod-based index

- **pod\_type** ( _None_): an optional pod type to use when creating a new
pod-based index

For detailed information on these parameters, see the
[Pinecone documentation](https://docs.pinecone.io/docs/indexes).

You can specify these parameters via any of the strategies described in the
previous section. Here’s an example of a [brain config](../fiftyone_concepts/brain.md#brain-config)
that configures a serverless index:

```python
{
    "similarity_backends": {
        "pinecone": {
            "index_name": "your-index",
            "index_type": "serverless",
            "metric": "cosine",
        }
    }
}

```

However, typically these parameters are directly passed to
`compute_similarity()` to configure
a specific new index:

```python
pinecone_index = fob.compute_similarity(
    ...
    backend="pinecone",
    brain_key="pinecone_index",
    index_name="your-index",
    index_type="serverless",
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
will not delete any associated Pinecone index, which you can do as follows:

```python
# Delete the Pinecone index
pinecone_index = dataset.load_brain_results(brain_key)
pinecone_index.cleanup()

```

## Examples [¶](\#examples "Permalink to this headline")

This section demonstrates how to perform some common vector search workflows on
a FiftyOne dataset using the Pinecone backend.

Note

All of the examples below assume you have configured your Pinecone API key
as described in [this section](#pinecone-setup).

### Create a similarity index [¶](\#create-a-similarity-index "Permalink to this headline")

In order to create a new Pinecone similarity index, you need to specify either
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
brain_key = "pinecone_index"

# Option 1: Compute embeddings on the fly from model name
fob.compute_similarity(
    dataset,
    model=model_name,
    backend="pinecone",
    brain_key=brain_key,
)

# Option 2: Compute embeddings on the fly from model instance
fob.compute_similarity(
    dataset,
    model=model,
    backend="pinecone",
    brain_key=brain_key,
)

# Option 3: Pass precomputed embeddings as a numpy array
embeddings = dataset.compute_embeddings(model)
fob.compute_similarity(
    dataset,
    embeddings=embeddings,
    backend="pinecone",
    brain_key=brain_key,
)

# Option 4: Pass precomputed embeddings by field name
dataset.compute_embeddings(model, embeddings_field="embeddings")
fob.compute_similarity(
    dataset,
    embeddings="embeddings",
    backend="pinecone",
    brain_key=brain_key,
)

```

Note

You can customize the Pinecone index by passing any
[supported parameters](#pinecone-config-parameters) as extra kwargs.

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
    backend="pinecone",
    brain_key="pinecone_patches",
)

```

Note

You can customize the Pinecone index by passing any
[supported parameters](#pinecone-config-parameters) as extra kwargs.

### Connect to an existing index [¶](\#connect-to-an-existing-index "Permalink to this headline")

If you have already created a Pinecone index storing the embedding vectors for
the samples or patches in your dataset, you can connect to it by passing the
`index_name` to
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
    index_name="your-index",            # the existing Pinecone index
    brain_key="pinecone_index",
    backend="pinecone",
)

```

### Add/remove embeddings from an index [¶](\#add-remove-embeddings-from-an-index "Permalink to this headline")

You can use
`add_to_index()`
and
`remove_from_index()`
to add and remove embeddings from an existing Pinecone index.

These methods can come in handy if you modify your FiftyOne dataset and need
to update the Pinecone index to reflect these changes:

```python
import numpy as np

import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

pinecone_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="pinecone_index",
    backend="pinecone",
)
print(pinecone_index.total_index_size)  # 200

view = dataset.take(10)
ids = view.values("id")

# Delete 10 samples from a dataset
dataset.delete_samples(view)

# Delete the corresponding vectors from the index
pinecone_index.remove_from_index(sample_ids=ids)

# Add 20 samples to a dataset
samples = [fo.Sample(filepath="tmp%d.jpg" % i) for i in range(20)]
sample_ids = dataset.add_samples(samples)

# Add corresponding embeddings to the index
embeddings = np.random.rand(20, 512)
pinecone_index.add_to_index(embeddings, sample_ids)

print(pinecone_index.total_index_size)  # 210

```

### Retrieve embeddings from an index [¶](\#retrieve-embeddings-from-an-index "Permalink to this headline")

You can use
`get_embeddings()`
to retrieve embeddings from a Pinecone index by ID:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

pinecone_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="pinecone_index",
    backend="pinecone",
)

# Retrieve embeddings for the entire dataset
ids = dataset.values("id")
embeddings, sample_ids, _ = pinecone_index.get_embeddings(sample_ids=ids)
print(embeddings.shape)  # (200, 512)
print(sample_ids.shape)  # (200,)

# Retrieve embeddings for a view
ids = dataset.take(10).values("id")
embeddings, sample_ids, _ = pinecone_index.get_embeddings(sample_ids=ids)
print(embeddings.shape)  # (10, 512)
print(sample_ids.shape)  # (10,)

```

### Querying a Pinecone index [¶](\#querying-a-pinecone-index "Permalink to this headline")

You can query a Pinecone index by appending a
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
    brain_key="pinecone_index",
    backend="pinecone",
)

# Query by vector
query = np.random.rand(512)  # matches the dimension of CLIP embeddings
view = dataset.sort_by_similarity(query, k=10, brain_key="pinecone_index")

# Query by sample ID
query = dataset.first().id
view = dataset.sort_by_similarity(query, k=10, brain_key="pinecone_index")

# Query by a list of IDs
query = [dataset.first().id, dataset.last().id]
view = dataset.sort_by_similarity(query, k=10, brain_key="pinecone_index")

# Query by text prompt
query = "a photo of a dog"
view = dataset.sort_by_similarity(query, k=10, brain_key="pinecone_index")

```

Note

Performing a similarity search on a [`DatasetView`](../api/fiftyone.core.view.html#fiftyone.core.view.DatasetView "fiftyone.core.view.DatasetView") will **only** return
results from the view; if the view contains samples that were not included
in the index, they will never be included in the result.

This means that you can index an entire [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") once and then perform
searches on subsets of the dataset by
[constructing views](../fiftyone_concepts/using_views.md#using-views) that contain the images of
interest.

### Accessing the Pinecone client [¶](\#accessing-the-pinecone-client "Permalink to this headline")

You can use the `index` property of a Pinecone index to directly access the
underlying Pinecone client instance and use its methods as desired:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

pinecone_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="pinecone_index",
    backend="pinecone",
)

print(pinecone_index.index)

```

### Advanced usage [¶](\#advanced-usage "Permalink to this headline")

As [previously mentioned](#pinecone-config-parameters), you can customize
your Pinecone indexes by providing optional parameters to
`compute_similarity()`.

Here’s an example of creating a similarity index backed by a customized
Pinecone index. Just for fun, we’ll specify a custom index name, use dot
product similarity, and populate the index for only a subset of our dataset:

```python
import fiftyone as fo
import fiftyone.brain as fob
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")

# Create a custom Pinecone index
pinecone_index = fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    embeddings=False,  # we'll add embeddings below
    metric="dotproduct",
    brain_key="pinecone_index",
    backend="pinecone",
    index_name="custom-pinecone-index",
)

# Add embeddings for a subset of the dataset
view = dataset.take(10)
embeddings, sample_ids, _ = pinecone_index.compute_embeddings(view)
pinecone_index.add_to_index(embeddings, sample_ids)

print(pinecone_index.index)

```
