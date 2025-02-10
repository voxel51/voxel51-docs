# Frequently Asked Questions [¶](\#frequently-asked-questions "Permalink to this headline")

## Can I open the FiftyOne App in a browser? [¶](\#can-i-open-the-fiftyone-app-in-a-browser "Permalink to this headline")

Yes! In fact, this is the default behavior. Unless you’re working
[in a notebook](#faq-notebook-support), the App will open in your default
web browser whenever you call
[`launch_app()`](../api/fiftyone.core.session.html#fiftyone.core.session.launch_app "fiftyone.core.session.launch_app") .

Check out the [environments guide](../fiftyone_concepts/running_environments.md#environments) to see how to use
FiftyOne in all common local, remote, cloud, and notebook environments.

## Which web browsers does the FiftyOne App support? [¶](\#which-web-browsers-does-the-fiftyone-app-support "Permalink to this headline")

The [FiftyOne App](../fiftyone_concepts/app.md#fiftyone-app) fully supports Chrome, Firefox, and
Safari.

You may find success using browsers like Edge, Opera, or Chromium, but your
mileage will vary. Internet Explorer is explicitly unsupported at this time.

## Why isn’t the App opening? Not connected to a session? [¶](\#why-isn-t-the-app-opening-not-connected-to-a-session "Permalink to this headline")

When you call [`fo.launch_app()`](../api/fiftyone.core.session.html#fiftyone.core.session.launch_app "fiftyone.core.session.launch_app") to
launch the [FiftyOne App](../fiftyone_concepts/app.md#fiftyone-app), the App will launch
asynchronously and return control to your Python process. The App will then
remain connected until the process exits.

If you are using the App in a script, you should use
[`session.wait()`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.wait "fiftyone.core.session.Session.wait") to block execution
until you close it manually:

```python
# Launch the App
session = fo.launch_app(...)

# (Perform any additional operations here)

# Blocks execution until the App is closed
session.wait()

```

If you launch the App in a script without including
[`session.wait()`](../api/fiftyone.core.session.html#fiftyone.core.session.Session.wait "fiftyone.core.session.Session.wait"), the App’s
connection will close when the script exits, and you will see a message like
“It looks like you are not connected to a session” in the browser tab that was
opened.

## Why can’t I open the App from a script on Windows? [¶](\#why-can-t-i-open-the-app-from-a-script-on-windows "Permalink to this headline")

If you are a Windows user launching the [FiftyOne App](../fiftyone_concepts/app.md#fiftyone-app) from
a script, you should use the pattern below to avoid
[multiprocessing issues](https://stackoverflow.com/q/20360686), since the App
is served via a separate process:

```python
import fiftyone as fo

dataset = fo.load_dataset(...)

if __name__ == "__main__":
    # Ensures that the App processes are safely launched on Windows
    session = fo.launch_app(dataset)
    session.wait()

```

See [this section](../fiftyone_concepts/app.md#creating-an-app-session) for more details.

## Can I use FiftyOne in a notebook? [¶](\#can-i-use-fiftyone-in-a-notebook "Permalink to this headline")

Yes! FiftyOne supports [Jupyter Notebooks](https://jupyter.org),
[Google Colab Notebooks](https://colab.research.google.com),
[Databricks Notebooks](https://docs.databricks.com/en/notebooks/index.html),
and [SageMaker Notebooks](https://aws.amazon.com/sagemaker/notebooks/).

All the usual FiftyOne commands can be run in notebook environments, and the
App will launch/update in the output of your notebook cells!

Check out the [notebook environment guide](../fiftyone_concepts/running_environments/#notebooks) for more
information about running FiftyOne in notebooks.

## Why isn’t the App loading in my cloud notebook? [¶](\#why-isn-t-the-app-loading-in-my-cloud-notebook "Permalink to this headline")

Except for [Google Colab](https://colab.research.google.com) and
[Databricks](https://docs.databricks.com/en/notebooks/index.html) which have
built-in App configuration, when working in a cloud notebook a
[proxy\_url](../fiftyone_concepts/config.md#configuring-proxy-url) should be set in your
[FiftyOne App config](../fiftyone_concepts/config.md#configuring-fiftyone-app).

## Can I use FiftyOne in a remote notebook? [¶](\#can-i-use-fiftyone-in-a-remote-notebook "Permalink to this headline")

Yes! It is possible to work with a Jupyter notebook in your local browser that
is served from a remote machine.

Refer to [this section](../fiftyone_concepts/running_environments.md#remote-notebooks) of the environment guide for
instructions to achieve this.

## Can I restrict access to my remote App instance? [¶](\#can-i-restrict-access-to-my-remote-app-instance "Permalink to this headline")

By default, [remote App sessions](../fiftyone_concepts/app.md#remote-session) will listen to any
connection to their ports. However, if desired, you can restrict access to an
App session to a particular IP address or hostname by
[following these instructions](../fiftyone_concepts/running_environments.md#restricting-app-address).

## Why aren’t plots appearing in my notebook? [¶](\#why-aren-t-plots-appearing-in-my-notebook "Permalink to this headline")

If you are trying to [view plots](../fiftyone_concepts/plots.md#interactive-plots) in a Jupyter
notebook but nothing appears after you call `plot.show()`, then you likely need
to [follow these instructions](../fiftyone_concepts/plots.md#working-in-notebooks) to install the
proper packages and/or Jupyter notebook extensions.

If the proper packages are installed but plots are still not displaying, try
including the following commands in your notebook before creating any plots:

```python
# Ensure that plotly.js is downloaded
import plotly.offline as po
po.init_notebook_mode(connected=True)

```

## Can I access data stored on a remote server? [¶](\#can-i-access-data-stored-on-a-remote-server "Permalink to this headline")

Yes! If you install FiftyOne on both your remote server and local machine, then
you can [load a dataset remotely](../fiftyone_concepts/running_environments.md#remote-data) and then explore it via an
[App session on your local machine](../fiftyone_concepts/app.md#creating-an-app-session).

## Can I access data stored in the cloud? [¶](\#can-i-access-data-stored-in-the-cloud "Permalink to this headline")

Yes! Check out [FiftyOne Teams](../teams/index.md#fiftyone-teams).

## What operating systems does FiftyOne support? [¶](\#what-operating-systems-does-fiftyone-support "Permalink to this headline")

FiftyOne officially supports the latest versions of MacOS and Windows, as well
as Amazon Linux 2 and 2023, Debian 9+ (x86\_64 only), Ubuntu 18.04+, and
RHEL/CentOS 7+.

Note

If installing on Ubuntu 22.04+, Debian, or RHEL/CentOS,
`fiftyone-db==0.4.3` must be requested.

```python
pip install fiftyone-db==0.4.3 fiftyone

```

## What image file types are supported? [¶](\#what-image-file-types-are-supported "Permalink to this headline")

In general, FiftyOne supports all image types
[supported by your browser](https://en.wikipedia.org/wiki/Comparison_of_web_browsers#Image_format_support),
which includes standard image types like JPEG, PNG, and BMP.

Some browsers like Safari natively support other image types such as TIFF,
while others do not. You may be able to install a browser extension to work
with additional image types, but Voxel51 does not currently recommend any
such extensions in particular.

## What video file types are supported? [¶](\#what-video-file-types-are-supported "Permalink to this headline")

Core methods that process videos can generally handle any
[codec supported by FFmpeg](https://www.ffmpeg.org/general.html#Video-Codecs).

The App can play any video codec that is supported by
[HTML5 video on your browser](https://en.wikipedia.org/wiki/HTML5_video#Browser_support),
including MP4 (H.264), WebM, and Ogg. If you try to view a video with an
unsupported codec in the App, you will be prompted to use the
[`reencode_videos()`](../api/fiftyone.utils.video.html#fiftyone.utils.video.reencode_videos "fiftyone.utils.video.reencode_videos") utility method
to re-encode the source video so it is viewable in the App.

Note

You must install [FFmpeg](https://ffmpeg.org) in order to work with video
datasets in FiftyOne. See [this page](../getting_started/basic/troubleshooting.md#troubleshooting-video) for
installation instructions.

## What label types are supported? [¶](\#what-label-types-are-supported "Permalink to this headline")

FiftyOne provides support for all of the following label types for both image
and video datasets:

- [Classifications](../fiftyone_concepts/using_datasets.md#classification)

- [Multilabel classifications](../fiftyone_concepts/using_datasets.md#multilabel-classification)

- [Object detections](../fiftyone_concepts/using_datasets.md#object-detection)

- [Instance segmentations](../fiftyone_concepts/using_datasets.md#instance-segmentation)

- [Polylines and polygons](../fiftyone_concepts/using_datasets.md#polylines)

- [Keypoints](../fiftyone_concepts/using_datasets.md#keypoints)

- [Semantic segmentations](../fiftyone_concepts/using_datasets.md#semantic-segmentation)

- [Geolocation data](../fiftyone_concepts/using_datasets.md#geolocation)


Check out [this guide](../fiftyone_concepts/dataset_creation/index.md#loading-custom-datasets) for simple recipes to
load labels in these formats.

## What happened to my datasets from previous sessions? [¶](\#what-happened-to-my-datasets-from-previous-sessions "Permalink to this headline")

By default, datasets are non-persistent, which means they are deleted from the
database whenever you exit (all) Python sessions in which you’ve imported
FiftyOne.

To make a dataset persistent, set its
[`persistent`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.persistent "fiftyone.core.dataset.Dataset.persistent") property to
`True`:

```python
import fiftyone as fo

# This dataset will be deleted when you exit Python
dataset = fo.Dataset("test")

# Now the dataset is permanent
dataset.persistent = True

```

See [this page](../fiftyone_concepts/using_datasets.md#dataset-persistence) for more details about dataset
persistence.

Note

FiftyOne does not store the raw data in datasets directly (only the
labels), so your source files on disk are never deleted!

## Why didn’t changes to my dataset save? [¶](\#why-didn-t-changes-to-my-dataset-save "Permalink to this headline")

Although **adding** samples to datasets immediately writes them to the
database, remember that any **edits** that you make to a
[sample](../fiftyone_concepts/using_datasets.md#adding-sample-fields) or its
[frame labels](../fiftyone_concepts/using_datasets.md#video-datasets) will not be written to the database until
you call [`sample.save()`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample.save "fiftyone.core.sample.Sample.save").

Similarly, **setting** the properties of a [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") object will be immediately
saved, but you must call
[`dataset.save()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.save "fiftyone.core.dataset.Dataset.save") whenever you
**edit** fields such as [`info`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.info "fiftyone.core.dataset.Dataset.info") or
[`classes`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.classes "fiftyone.core.dataset.Dataset.classes") in-place.

Refer to [this section](../fiftyone_concepts/using_datasets.md#adding-sample-fields) for more details about
modifying samples and [this section](../fiftyone_concepts/using_datasets.md#storing-info) for more details about
storing dataset-level information.

```python
import fiftyone as fo

dataset = fo.Dataset(...)
new_samples = [...]

# Setting a property is automatically saved
dataset.persistent = True

dataset.info["hello"] = "world"
dataset.save()  # don't forget this!

# Added samples are automatically saved
dataset.add_samples(new_samples)

for sample in dataset:
    sample["field"] = 51
    sample.save()  # don't forget this!

```

## Can I share a dataset with someone else? [¶](\#can-i-share-a-dataset-with-someone-else "Permalink to this headline")

Yes! Here’s a couple options:

**Option 1: Export and share**

You can easily [export a dataset](../fiftyone_concepts/export_datasets.md#exporting-datasets) in one line of
code, zip it, and share the zip with your collaborator, who can then
[load it in a few lines of code](../fiftyone_concepts/dataset_creation/datasets.md#loading-datasets-from-disk).

**Option 2: Sharing a remote session**

Alternatively, [see this FAQ](#faq-multiple-sessions-same-dataset) for
instructions on launching a remote session and inviting collaborator(s) to
connect to it from their local machines.

## Can I use FiftyOne in multiple shells? [¶](\#can-i-use-fiftyone-in-multiple-shells "Permalink to this headline")

Yes! Any changes you make to a dataset or its samples in one shell will be
reflected in the other shells whenever you access that dataset. You can also
launch [multiple App instances](#faq-multiple-apps).

Working with the same dataset in multiple shells simultaneously is generally
seamless, even if you are editing the dataset, as the [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") class does not
store its [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") objects in-memory, it loads them from the database only when
they are requested. Therefore, if you add or modify a [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") in one shell,
you will immediately have access to the updates the next time you request that
[`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") in other shells.

The one exception to this rule is that [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") and [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") objects
themselves are singletons, so if you hold references to these objects
in-memory, they will not be automatically updated by re-accessing them, since
the existing instances will be returned back to you.

If a dataset may have been changed by another process, you can always manually
call [`Dataset.reload()`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset.reload "fiftyone.core.dataset.Dataset.reload") to reload
the [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") object and all in-memory [`Sample`](../api/fiftyone.core.sample.html#fiftyone.core.sample.Sample "fiftyone.core.sample.Sample") instances that belong to it.

## Can I launch multiple App instances on a machine? [¶](\#can-i-launch-multiple-app-instances-on-a-machine "Permalink to this headline")

Yes! Simply specify a different `port` for each App instance that you create.

## Can I connect multiple App instances to the same dataset? [¶](\#can-i-connect-multiple-app-instances-to-the-same-dataset "Permalink to this headline")

Yes, multiple App instances can be connected to the same [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") via remote
sessions.

Note

Keep in mind that all users must have ssh access to the system from which
the remote session(s) are launched in order to connect to them.

You can achieve multiple connections in two ways:

**Option 1: Same dataset, multiple sessions**

The typical way to connect multiple App instances to the same dataset is to
create a separate remote session instance on the machine that houses the
[`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") of interest for each local App instance that you want to create.
[See this FAQ](#faq-serve-multiple-remote-sessions) for instructions on
doing this.

**Option 2: Same dataset, same session**

Another option is to connect multiple App instances to a single remote session.

First, [create a remote session](../fiftyone_concepts/app.md#remote-session) on the system that
houses the [`Dataset`](../api/fiftyone.core.dataset.html#fiftyone.core.dataset.Dataset "fiftyone.core.dataset.Dataset") using either the CLI or Python:

Then one or more users can use the CLI on their local machine to
[connect to the remote session](../fiftyone_concepts/app.md#remote-app-local-machine).

Note

When multiple App instances are connected to the same [`Session`](../api/fiftyone.core.session.html#fiftyone.core.session.Session "fiftyone.core.session.Session"), any
actions taken that affect the session (e.g.,
[loading a view](../fiftyone_concepts/app.md#app-create-view)) will be reflected in all connected
App instances.

## Can I connect to multiple remote sessions? [¶](\#can-i-connect-to-multiple-remote-sessions "Permalink to this headline")

Yes, you can launch multiple instances of the App locally, each connected to a
different remote session.

The key here is to specify a different _local port_ for each App instance that
you create.

Suppose you are connecting to multiple remote [`Session`](../api/fiftyone.core.session.html#fiftyone.core.session.Session "fiftyone.core.session.Session") instances that were
created on different remote systems (e.g., an EC2 instance and a remote server
that you own), using commands similar to:

On your local machine, you can
[connect to these remote sessions](../fiftyone_concepts/app.md#remote-app-local-machine) using a
different local port `XXXX` and `YYYY` for each.

If you do not have FiftyOne installed on your local machine, open a new
terminal window on your local machine and execute the following command to
setup port forwarding to connect to your remote sessions:

```python
ssh -N -L XXXX:localhost:RRRR1 [<username1>@]<hostname1>
# Then open `http://localhost:XXXX` in your web browser

```

```python
ssh -N -L YYYY:localhost:RRRR2 [<username2>@]<hostname2>
# Then open `http://localhost:YYYY` in your web browser

```

In the above, `[<username#>@]<hostname#>` refers to a remote machine and
`RRRR#` is the remote port that you used for the remote session.

Alternatively, if you have FiftyOne installed on your local machine, you can
[use the CLI](../cli/index.md#cli-fiftyone-app-connect) to automatically configure port
forwarding and open the App in your browser as follows:

```python
# Connect to first remote session
fiftyone app connect \
    --destination [<username1>@]<hostname1> \
    --port RRRR1
    --local-port XXXX

```

```python
# Connect to second remote session
fiftyone app connect \
    --destination [<username2>@]<hostname2> \
    --port RRRR2
    --local-port YYYY

```

Note

You can also serve multiple remote sessions
[from the same machine](#faq-serve-multiple-remote-sessions).

## Can I serve multiple remote sessions from a machine? [¶](\#can-i-serve-multiple-remote-sessions-from-a-machine "Permalink to this headline")

Yes, you can create multiple remote sessions on the same remote machine by
specifying different ports for each [`Session`](../api/fiftyone.core.session.html#fiftyone.core.session.Session "fiftyone.core.session.Session") that you create:

On your local machine(s), you can now
[connect to the remote sessions](../fiftyone_concepts/app.md#remote-app-local-machine). Connections
can be set up using port forwarding in the following way:

```python
ssh -N -L WWWW:localhost:XXXX [<username>@]<hostname>
# Then open `http://localhost:WWWW` in your web browser

```

```python
ssh -N -L ZZZZ:localhost:YYYY [<username>@]<hostname>
# Then open `http://localhost:ZZZZ` in your web browser

```

In the above, `[<username>@]<hostname>` refers to your remote machine, and
`WWWW` and `ZZZZ` are any 4 digit ports on your local machine(s).

Alternatively, if you have FiftyOne installed on your local machine, you can
[use the CLI](../cli/index.md#cli-fiftyone-app-connect) to automatically configure port
forwarding and open the App in your browser as follows:

```python
# On a local machine

# Connect to first remote session
fiftyone app connect \
    --destination [<username>@]<hostname> \
    --port XXXX \
    --local-port WWWW

```

```python
# On a local machine

# Connect to second remote session
fiftyone app connect \
    --destination [<username>@]<hostname> \
    --port YYYY \
    --local-port ZZZZ

```

## Can I use my own MongoDB database? [¶](\#can-i-use-my-own-mongodb-database "Permalink to this headline")

Yes, you can configure FiftyOne to connect to your own MongoDB instance by
setting the `database_uri` property of your
[FiftyOne config](../fiftyone_concepts/config.md#configuring-fiftyone). Refer to
[this page](../fiftyone_concepts/config.md#configuring-mongodb-connection) for more information.

## Too many open files in system? [¶](\#too-many-open-files-in-system "Permalink to this headline")

If you are a MacOS user and see a “too many open files in system” error when
performing import/export operations with FiftyOne, then you likely need to
increase the open files limit for your OS.

Following the instructions in [this post](https://superuser.com/a/443168)
should resolve the issue for you.

## Can I downgrade to an older version of FiftyOne? [¶](\#can-i-downgrade-to-an-older-version-of-fiftyone "Permalink to this headline")

Certainly, refer to [these instructions](../getting_started/basic/install.md#downgrading-fiftyone).

## Are the Brain methods open source? [¶](\#are-the-brain-methods-open-source "Permalink to this headline")

Yes, the [FiftyOne Brain](https://github.com/voxel51/fiftyone-brain) methods are open
source.

Check out the [Brain documentation](../fiftyone_concepts/brain.md#fiftyone-brain) for detailed
instructions on using the various Brain methods.

## Does FiftyOne track me? [¶](\#does-fiftyone-track-me "Permalink to this headline")

FiftyOne tracks anonymous UUID-based usage of the App by default. We are a
small team building an open source project, and basic knowledge of how users
are engaging with the project is critical to informing the roadmap of the
project.

Note

You can disable tracking by setting the `do_not_track` flag of your
[FiftyOne config](../fiftyone_concepts/config.md#configuring-fiftyone).

