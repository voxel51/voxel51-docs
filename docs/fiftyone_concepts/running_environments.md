# FiftyOne Environments [¶](\#fiftyone-environments "Permalink to this headline")

This guide describes best practices for using FiftyOne with data stored in
various environments, including local machines, remote servers, and cloud
storage.

## Terminology [¶](\#terminology "Permalink to this headline")

- [Local machine](#local-data): Data is stored on the same computer that
will be used to launch the App


- [Remote machine](#remote-data): Data is stored on disk on a separate
machine (typically a remote server) from the one that will be used to launch
the App

- [Notebooks](#notebooks): You are working from a
[Jupyter Notebook](https://jupyter.org),
[Google Colab Notebook](https://colab.research.google.com), or
[Databricks Notebook](https://docs.databricks.com/en/notebooks/index.html) [SageMaker Notebook](https://aws.amazon.com/sagemaker/notebooks/)

- [Cloud storage](#cloud-storage): Data is stored in a cloud bucket
(e.g., [S3](#aws), [GCS](#google-cloud), or [Azure](#azure))


## Local data [¶](\#local-data "Permalink to this headline")

When working with data that is stored on disk on a machine with a display, you
can directly [load a dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) and then
[launch the App](../fiftyone_concepts/app.md#creating-an-app-session):

```python
# On local machine
import fiftyone as fo

dataset = fo.Dataset("my-dataset")

session = fo.launch_app(dataset)  # (optional) port=XXXX

```

From here, you can explore the dataset interactively from the App and from your
Python shell by manipulating the
[`session object`](../api/fiftyone.core.session.html#fiftyone.core.session.Session "fiftyone.core.session.Session").

Note

You can use custom ports when launching the App in order to operate
multiple App instances simultaneously on your machine.

## Remote data [¶](\#remote-data "Permalink to this headline")

FiftyOne supports working with data that is stored on a remote machine that you
have `ssh` access to. The basic workflow is to load a dataset on the remote
machine via the FiftyOne Python library, launch a
[remote session](../fiftyone_concepts/app.md#remote-session), and connect to the session on your
local machine where you can then interact with the App.

First, `ssh` into your remote machine and
[install FiftyOne](../getting_started/basic/install.md#installing-fiftyone) if necessary.

Then [load a dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) using Python on the remote
machine and launch a remote session:

```python
# On remote machine
import fiftyone as fo

dataset = fo.load_dataset(...)

session = fo.launch_app(dataset, remote=True)  # optional: port=XXXX

```

Leave the Python REPL running and follow the instructions for connecting to
this session remotely that were printed to your terminal (also described
below).

Note

You can manipulate the `session` object on the remote machine as usual to
programmatically interact with the App instance that you view locally.

To connect to your remote session, open a new terminal window on your local
machine and execute the following command to setup port forwarding to connect
to your remote session:

```python
# On local machine
ssh -N -L 5151:127.0.0.1:XXXX [<username>@]<hostname>

```

Leave this process running and open [http://localhost:5151](http://localhost:5151) in your browser to
access the App.

In the above, `[<username>@]<hostname>` specifies the remote machine to connect
to, `XXXX` refers to the port that you chose when you launched the session on
your remote machine (the default is 5151), and `5151` specifies the local port
to use to connect to the App (and can be customized).

Alternatively, if you have FiftyOne installed on your local machine, you can
[use the CLI](../cli/index.md#cli-fiftyone-app-connect) to automatically configure port
forwarding and open the App in your browser as follows:

```python
# On local machine
fiftyone app connect --destination [<username>@]<hostname>

```

If you choose a custom port `XXXX` on the remote machine, add a `--port XXXX`
flag to the above command.

If you would like to use a custom local port, add a `--local-port YYYY` flag
to the above command.

Note

You can customize the local/remote ports used when launching remote
sessions in order to connect/service multiple remote sessions
simultaneously.

Note

If you use ssh keys to connect to your remote machine, you can use the
optional `--ssh-key` argument of the
[fiftyone app connect](../cli/index.md#cli-fiftyone-app-connect) command.

However, if you are using this key regularly,
[it is recommended](https://unix.stackexchange.com/a/494485) to add it
to your `~/.ssh/config` as the default `IdentityFile`.

### Restricting the App address [¶](\#restricting-the-app-address "Permalink to this headline")

By default, the App will listen on `localhost`. However, you can provide the
optional `address` parameter to
[`launch_app()`](../api/fiftyone.core.session.html#fiftyone.core.session.launch_app "fiftyone.core.session.launch_app") to specify a particular
IP address or hostname for the App to listen on.

Using the default of `localhost` means the App can only be accessed from the
local machine or a machine that was able to setup ssh port forwarding as
described in the previous section.

An alternative is to set the App address to `"0.0.0.0"` so that the App can be
accessed from a remote host or from the local machine itself. Using `"0.0.0.0"`
will bind the App to all available interfaces and will allow access to the App
from any remote resource with access to your network.

```python
import fiftyone as fo

dataset = fo.load_dataset(...)

# Enable connections from remote hosts
session = fo.launch_app(dataset, remote=True, address="0.0.0.0")

```

If desired, you can permanently configure an App address by setting the
`default_app_address` of your [FiftyOne config](../fiftyone_concepts/config.md#configuring-fiftyone).
You can achieve this by adding the following entry to your
`~/.fiftyone/config.json` file:

```python
{
    "default_app_address": "0.0.0.0"
}

```

or by setting the following environment variable:

```python
export FIFTYONE_DEFAULT_APP_ADDRESS='0.0.0.0'

```

## Notebooks [¶](\#notebooks "Permalink to this headline")

FiftyOne officially supports [Jupyter Notebooks](https://jupyter.org),
[Google Colab Notebooks](https://colab.research.google.com),
[Databricks Notebooks](https://docs.databricks.com/en/notebooks/index.html).
App support is also available in
[SageMaker Notebooks](https://aws.amazon.com/sagemaker/notebooks/) and any
cloud notebook that has an accessible network proxy via configured
[proxy\_url](../fiftyone_concepts/config.md#configuring-proxy-url).

To use FiftyOne in a notebook, simply install `fiftyone` via `pip`:

```python
!pip install fiftyone

```

and load datasets as usual. When you run
[`launch_app()`](../api/fiftyone.core.session.html#fiftyone.core.session.launch_app "fiftyone.core.session.launch_app") in a notebook, an App
window will be opened in the output of your current cell.

```python
import fiftyone as fo

dataset = fo.Dataset("my-dataset")

# Creates a session and opens the App in the output of the cell
session = fo.launch_app(dataset)

```

Any time you update the state of your `session` object; e.g., by setting
[`session.dataset`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.dataset "fiftyone.core.session.Session.dataset") or
[`session.view`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.view "fiftyone.core.session.Session.view"), a new App window
will be automatically opened in the output of the current cell. The previously
active App will be “frozen”, i.e., replaced with a screenshot of its current
state.

```python
# A new App window will be created in the output of this cell, and the
# previously active App instance will be replaced with a screenshot
session.view = dataset.take(10)

```

You can reactivate a frozen App instance from the same notebook session by
clicking on the screenshot.

Note

Reactivating a frozen App instance will load the current state of the
`session` object, not the state in which the screenshot was taken.

To reactivate an App instance from a previous session, e.g., when running a
notebook downloaded from the web for the first time, you must (re)run the cell.

You can manually replace the active App instance with a screenshot by calling
[`session.freeze()`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.freeze "fiftyone.core.session.Session.freeze"). This is
useful when you are finished with your notebook and ready to share it with
others, as an active App instance itself cannot be viewed outside of the
current notebook session.

```python
# Replace active App instance with screenshot so App state is viewable offline
session.freeze()

```

### Manually controlling App instances [¶](\#manually-controlling-app-instances "Permalink to this headline")

If you would like to manually control when new App instances are created in a
notebook, you can pass the `auto=False` flag to
[`launch_app()`](../api/fiftyone.core.session.html#fiftyone.core.session.launch_app "fiftyone.core.session.launch_app"):

```python
# Creates a session but does not open an App instance
session = fo.launch_app(dataset, auto=False)

```

When `auto=False` is provided, a new App window is created only when you call
[`session.show()`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.show "fiftyone.core.session.Session.show"):

```python
# Update the session's view; no App window is created
session.view = dataset.take(10)

# In another cell

# Now open an App window in the cell's output
session.show()

```

As usual, this App window will remain connected to your `session` object, so
it will stay in-sync with your session whenever it is active.

Note

If you run [`session.show()`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.show "fiftyone.core.session.Session.show") in
multiple cells, only the most recently created App window will be active,
i.e., synced with the `session` object.

You can reactivate an older cell by clicking the link in the deactivated
App window, or by running the cell again. This will deactivate the
previously active cell.

### Opening the App in a dedicated tab [¶](\#opening-the-app-in-a-dedicated-tab "Permalink to this headline")

If you are working from a Jupyter notebook, you can open the App in a separate
browser tab rather than working with it in cell output(s).

To do this, pass the `auto=False` flag to
[`launch_app()`](../api/fiftyone.core.session.html#fiftyone.core.session.launch_app "fiftyone.core.session.launch_app") when you launch the
App (so that additional App instances will not be created as you work) and then
call [`session.open_tab()`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.open_tab "fiftyone.core.session.Session.open_tab"):

```python
# Launch the App in a dedicated browser tab
session = fo.launch_app(dataset, auto=False)
session.open_tab()

```

### Remote notebooks [¶](\#remote-notebooks "Permalink to this headline")

You can also work in a Jupyter notebook in your local browser that is
[served from a remote machine](https://ljvmiranda921.github.io/notebook/2018/01/31/running-a-jupyter-notebook)
where your data is located. Follow the instructions below to achieve this.

**On the remote machine:**

Start the Jupyter server on a port of your choice:

```python
# On remote machine
jupyter notebook --no-browser --port=XXXX /path/to/notebook.ipynb

```

**On your local machine:**

Back on your local machine, you will need to forward the remote port `XXXX` to
a local port (we’ll also use `XXXX` here, for consistency):

```python
# On local machine
ssh -N -L XXXX:localhost:XXXX [<username>@]<hostname>

```

Now open `localhost:XXXX` in your browser and you should find your notebook!

If your notebook launches the [FiftyOne App](../fiftyone_concepts/app.md#fiftyone-app), you will also
need to forward the port used by the App to your local machine. By default,
the App uses port `5151`, but you can [specify any port](#remote-data),
say `YYYY`, not currently in use on your remote machine:

```python
# On local machine
ssh -N -L 5151:localhost:YYYY [<username>@]<hostname>

```

**In your Jupyter notebook:**

When you launch the [FiftyOne App](../fiftyone_concepts/app.md#fiftyone-app) in your notebook, you
should now see the App as expected!

```python
# Launch the App in a notebook cell
session = fo.launch_app(dataset)  # port=YYYY

```

If you chose a port `YYYY` other than the default `5151`, you will need to
specify it when launching App instances per the commented argument above.

Note that you can also open the App
[in a dedicated tab](#opening-app-dedicated-tab):

```python
# Launch the App in a dedicated browser tab
session = fo.launch_app(dataset, auto=False)  # port=YYYY
session.open_tab()

```

## Docker [¶](\#docker "Permalink to this headline")

The FiftyOne repository contains a
[Dockerfile](https://github.com/voxel51/fiftyone/blob/develop/Dockerfile)
that you can use/customize to build and run Docker images containing source
or release builds of FiftyOne.

### Building an image [¶](\#building-an-image "Permalink to this headline")

First, clone the repository:

```python
git clone https://github.com/voxel51/fiftyone
cd fiftyone

```

If you want a source install of FiftyOne, then build a wheel:

```python
make python

```

If you want to install a FiftyOne release, then make the suggested modification
in the
[Dockerfile](https://github.com/voxel51/fiftyone/blob/develop/Dockerfile).

Next, build the image:

```python
docker build -t voxel51/fiftyone .

```

The default image uses Python 3.11, but you can customize these
via optional build arguments:

```python
docker build \
    --build-arg PYTHON_VERSION=3.10 \
    -t voxel51/fiftyone .

```

Refer to the
[Dockerfile](https://github.com/voxel51/fiftyone/blob/develop/Dockerfile) for
additional Python packages that you may wish to include in your build.

### Running an image [¶](\#running-an-image "Permalink to this headline")

The image is designed to persist all data in a single `/fiftyone` directory
with the following organization:

```python
/fiftyone/
    db/             # FIFTYONE_DATABASE_DIR
    default/        # FIFTYONE_DEFAULT_DATASET_DIR
    zoo/
        datasets/   # FIFTYONE_DATASET_ZOO_DIR
        models/     # FIFTYONE_MODEL_ZOO_DIR

```

Therefore, to run a container, you should mount `/fiftyone` as a local volume
via `--mount` or `-v`, as shown below:

```python
SHARED_DIR=/path/to/shared/dir

docker run -v ${SHARED_DIR}:/fiftyone -p 5151:5151 -it voxel51/fiftyone

```

The `-p 5151:5151` option is required so that when you
[launch the App](../fiftyone_concepts/app.md#creating-an-app-session) from within the container you
can connect to it at [http://localhost:5151](http://localhost:5151) in your browser.

You can also include the `-e` or `--env-file` options if you need to further
[configure FiftyOne](../fiftyone_concepts/config.md#configuring-fiftyone).

By default, running the image launches an IPython shell, which you can use as
normal:

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")
session = fo.launch_app(dataset)

```

Note

Any datasets you create inside the Docker image must refer to media
files within `SHARED_DIR` or another mounted volume if you intend to work
with datasets between sessions.

Note

FiftyOne should automatically detect that it is running inside a Docker
container. However, if you are unable to load the App in your browser, you
may need to manually [set the App address](#restricting-app-address)
to `0.0.0.0`:

```python
session = fo.launch_app(..., address="0.0.0.0")

```

### Connecting to a localhost database [¶](\#connecting-to-a-localhost-database "Permalink to this headline")

If you are using a
[self-managed database](../fiftyone_concepts/config.md#configuring-mongodb-connection) that you
ordinarily connect to via a URI like `mongodb://localhost`, then you will need
to tweak this slightly when working in Docker. See
[this question](https://stackoverflow.com/q/24319662) for details.

On Linux, include `--network="host"` in your `docker run` command and use
`mongodb://127.0.0.1` for your URI.

On Mac or Windows, use `mongodb://host.docker.internal` for your URI.

## Cloud storage [¶](\#cloud-storage "Permalink to this headline")

For prototyping, it is _possible_ to work with data in cloud storage buckets in
FiftyOne by mounting the buckets as local drives.

The following sections describe how to do this in the [AWS](#aws),
[Google Cloud](#google-cloud), and [Microsoft Azure](#azure)
environments.

Warning

Mounting cloud buckets using the techniques below is not performant and is
not recommended or officially supported. It is useful only for prototyping.

Our recommended, scalable approach to work with cloud-backed data is
[FiftyOne Teams](../teams/index.md#fiftyone-teams), an enterprise deployment of
FiftyOne with multiuser collaboration features, native cloud dataset
support, and much more!

### AWS [¶](\#aws "Permalink to this headline")

If your data is stored in an AWS S3 bucket, you can mount the bucket as a local
drive on an EC2 instance and then access the data using the standard workflow
for remote data.

The steps below outline the process.

**Step 1**

[Create an EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html).

**Step 2**

Now [ssh into the instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html)
and [install FiftyOne](../getting_started/basic/install.md#installing-fiftyone) if necessary.

```python
# On remote machine
pip install fiftyone

```

Note

You may need to [install some system packages](#compute-instance-setup)
on your compute instance instance in order to run FiftyOne.

**Step 3**

Mount the S3 bucket as a local drive.

You can use [s3fs-fuse](https://github.com/s3fs-fuse/s3fs-fuse) to do this.
You will need to make a `.passwd-s3fs` file that contains your AWS credentials
as outlined in the [s3fs-fuse README](https://github.com/s3fs-fuse/s3fs-fuse).

```python
# On remote machine
s3fs <bucket-name> /path/to/mount/point \
    -o passwd_file=.passwd-s3fs \
    -o umask=0007,uid=<your-user-id>

```

**Step 4**

Now that you can access your data from the compute instance, start up Python
and [create a FiftyOne dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) whose filepaths are in
the mount point you specified above. Then you can launch the App and work with
it locally in your browser using [remote sessions](#remote-data).

### Google Cloud [¶](\#google-cloud "Permalink to this headline")

If your data is stored in a Google Cloud storage bucket, you can mount the
bucket as a local drive on a GC compute instance and then access the data using
the standard workflow for remote data.

The steps below outline the process.

**Step 1**

[Create a GC compute instance](https://cloud.google.com/compute/docs/quickstart-linux).

**Step 2**

Now [ssh into the instance](https://cloud.google.com/compute/docs/quickstart-linux#connect_to_your_instance)
and [install FiftyOne](../getting_started/basic/install.md#installing-fiftyone) if necessary.

```python
# On remote machine
pip install fiftyone

```

Note

You may need to [install some system packages](#compute-instance-setup)
on your compute instance instance in order to run FiftyOne.

**Step 3**

Mount the GCS bucket as a local drive.

You can use [gcsfuse](https://github.com/GoogleCloudPlatform/gcsfuse) to do
this:

```python
# On remote machine
gcsfuse --implicit-dirs my-bucket /path/to/mount

```

**Step 4**

Now that you can access your data from the compute instance, start up Python
and [create a FiftyOne dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) whose filepaths are in
the mount point you specified above. Then you can launch the App and work with
it locally in your browser using [remote sessions](#remote-data).

### Microsoft Azure [¶](\#microsoft-azure "Permalink to this headline")

If your data is stored in an Azure storage bucket, you can mount the bucket as
a local drive on an Azure compute instance and then access the data using the
standard workflow for remote data.

The steps below outline the process.

**Step 1**

[Create an Azure compute instance](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal).

**Step 2**

Now
[ssh into the instance](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal#connect-to-virtual-machine)
and [install FiftyOne](../getting_started/basic/install.md#installing-fiftyone) if necessary.

```python
# On remote machine
pip install fiftyone

```

Note

You may need to [install some system packages](#compute-instance-setup)
on your compute instance instance in order to run FiftyOne.

**Step 3**

Mount the Azure storage container in the instance.

This is fairly straightforward if your data is stored in a blob container.
You can use [blobfuse](https://github.com/Azure/azure-storage-fuse) for this.

**Step 4**

Now that you can access your data from the compute instance, start up Python
and [create a FiftyOne dataset](../fiftyone_concepts/dataset_creation/index.md#loading-datasets) whose filepaths are in
the mount point you specified above. Then you can launch the App and work with
it locally in your browser using [remote sessions](#remote-data).

## Setting up a cloud instance [¶](\#setting-up-a-cloud-instance "Permalink to this headline")

When you create a fresh cloud compute instance, you may need to install some
system packages in order to install and use FiftyOne.

For example, the script below shows a set of commands that may be used to
configure a Debian-like Linux instance, after which you should be able to
successfully [install FiftyOne](../getting_started/basic/install.md#installing-fiftyone).

```python
# Example setup script for a Debian-like virtual machine

# System packages
sudo apt update
sudo apt -y upgrade
sudo apt install -y build-essential
sudo apt install -y unzip
sudo apt install -y cmake
sudo apt install -y cmake-data
sudo apt install -y pkg-config
sudo apt install -y libsm6
sudo apt install -y libxext6
sudo apt install -y libssl-dev
sudo apt install -y libffi-dev
sudo apt install -y libxml2-dev
sudo apt install -y libxslt1-dev
sudo apt install -y zlib1g-dev
sudo apt install -y python3
sudo apt install -y python-dev
sudo apt install -y python3-dev
sudo apt install -y python3-pip
sudo apt install -y python3-venv
sudo apt install -y ffmpeg  # if working with video

# (Recommended) Create a virtual environment
python3 -m venv fiftyone-env
. fiftyone-env/bin/activate

# Python packages
pip install --upgrade pip setuptools wheel build
pip install ipython

```

