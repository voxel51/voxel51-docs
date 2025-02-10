# FiftyOne Installation [¶](\#fiftyone-installation "Permalink to this headline")

Note

Need to collaborate on your datasets? Check out
[FiftyOne Teams](../../teams/index.md#fiftyone-teams)!

## Prerequisites [¶](\#prerequisites "Permalink to this headline")

You will need a working Python installation. FiftyOne currently requires
**Python 3.9 - 3.11**

On Linux, we recommend installing Python through your system package manager
(APT, YUM, etc.) if it is available. On other platforms, Python can be
downloaded [from python.org](https://www.python.org/downloads). To verify that
a suitable Python version is installed and accessible, run `python --version`.

We encourage installing FiftyOne in a virtual environment. See
[setting up a virtual environment](virtualenv.md) for more details.

## Installing FiftyOne [¶](\#installing-fiftyone "Permalink to this headline")

To install FiftyOne, ensure you have activated any virtual environment that you
are using, then run:

```python
pip install fiftyone

```

This will install FiftyOne and all of its dependencies. Once this has
completed, you can verify that FiftyOne is installed in your virtual
environment by importing the `fiftyone` package:

```python
$ python
>>>
>>> import fiftyone as fo
>>>

```

A successful installation of FiftyOne should result in no output when
`fiftyone` is imported. See [this section](#install-troubleshooting) for
install troubleshooting tips.

If you want to work with video datasets, you’ll also need to install
[FFmpeg](https://ffmpeg.org):

## Quickstart [¶](\#quickstart "Permalink to this headline")

Dive right into FiftyOne by opening a Python shell and running the snippet
below, which downloads a [small dataset](../../data/dataset_zoo/datasets.md#dataset-zoo-quickstart) and
launches the [FiftyOne App](../../fiftyone_concepts/app.md#fiftyone-app) so you can explore it!

```python
import fiftyone as fo
import fiftyone.zoo as foz

dataset = foz.load_zoo_dataset("quickstart")
session = fo.launch_app(dataset)

```

Note that if you are running this code in a script, you must include
[`session.wait()`](../../api/fiftyone.core.session.html#fiftyone.core.session.Session.wait "fiftyone.core.session.Session.wait") to block execution
until you close the App. See [this page](../../fiftyone_concepts/app.md#creating-an-app-session) for
more information.

## Troubleshooting [¶](\#troubleshooting "Permalink to this headline")

If you run into any installation issues, review the suggestions below or check
the [troubleshooting page](troubleshooting.md#troubleshooting) for more details.

Note

Most installation issues can be fixed by upgrading some packages and then
rerunning the FiftyOne install:

```python
pip install --upgrade pip setuptools wheel build
pip install fiftyone

```

**Mac users:**

- You must have the
[XCode Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
package installed on your machine. You likely already have it, but if you
encounter an error message like
`error: command 'clang' failed with exit status 1`, then you may need to
install it via `xcode-select --install`, or see
[this page](https://stackoverflow.com/q/9329243) for other options.


**Linux users:**

- The `psutil` package may require Python headers to be installed on your
system. On Debian-based distributions, these are available in the
`python3-dev` package.

- If you encounter an error related to MongoDB failing to start, such as `Could
not find mongod`, you may need to install additional packages. See the
[alternative Linux builds](troubleshooting.md#troubleshooting-mongodb) for details.


**Windows users:**

- If you encounter a `psutil.NoSuchProcessExists` when importing `fiftyone`,
you will need to install the 64-bit Visual Studio 2015 C++ redistributable
library. See [here](troubleshooting.md#troubleshooting-mongodb-windows) for
instructions.


## Installing extras [¶](\#installing-extras "Permalink to this headline")

Various tutorials and guides that we provide on this site require additional
packages in order to run. If you encounter a missing package, you will see
helpful instructions on what you need to install. Alternatively, you can
preemptively install what you’ll need by installing the following additional
packages via `pip` in your virtual environment:

- `ipython` to follow along with interactive examples more easily (note that
a system-wide IPython installation will _not_ work in a virtual environment,
even if it is accessible)

- `torch` and `torchvision` for examples requiring PyTorch. The installation
process can vary depending on your system, so consult the
[PyTorch documentation](https://pytorch.org/get-started/locally/) for
specific instructions.

- `tensorflow` for examples requiring TensorFlow. The installation process
can vary depending on your system, so consult the
[Tensorflow documentation](https://www.tensorflow.org/install) for specific
instructions.

- `tensorflow-datasets` for examples that rely on loading
[TensorFlow datasets](https://www.tensorflow.org/datasets)

- [FFmpeg](https://ffmpeg.org), in order to work with video datasets in
FiftyOne. See [this page](troubleshooting.md#troubleshooting-video) for installation
instructions.


Note

FiftyOne does not strictly require any of these packages, so you can install
only what you need. If you run something that requires an additional package,
you will see a helpful message telling you what to install.

## Upgrading FiftyOne [¶](\#upgrading-fiftyone "Permalink to this headline")

You can upgrade an existing FiftyOne installation by passing the `--upgrade`
option to `pip install`:

```python
pip install --upgrade fiftyone

```

Note

New versions of FiftyOne occasionally introduce data model changes that
require database migrations after you upgrade. Rest assured, these migrations
will be **automatically** performed on a per-dataset basis whenever you load
a dataset for the first time in a newer version of FiftyOne.

Note

If you are working with a
[custom/shared MongoDB database](../../fiftyone_concepts/config.md#configuring-mongodb-connection), you
can use [database admin privileges](../../fiftyone_concepts/config.md#database-migrations) to control
which clients are allowed to upgrade your FiftyOne deployment.

## Downgrading FiftyOne [¶](\#downgrading-fiftyone "Permalink to this headline")

If you need to downgrade to an older version of FiftyOne for any reason, you
can do so.

Since new releases occasionally introduce backwards-incompatible changes to the
data model, you must use the [fiftyone migrate](../../cli/index.md#cli-fiftyone-migrate)
command to perform any necessary downward database migrations
**before installing the older version of FiftyOne**.

Here’s the workflow for downgrading to an older version of FiftyOne:

```python
# The version that you wish to downgrade to
VERSION=0.15.1

# Migrate the database
fiftyone migrate --all -v $VERSION

# Now install the older version of `fiftyone`
pip install fiftyone==$VERSION

# Optional: verify that your datasets were migrated
fiftyone migrate --info

```

If you are reading this after encountering an error resulting from downgrading
your `fiftyone` package without first running
[fiftyone migrate](../../cli/index.md#cli-fiftyone-migrate), don’t worry, you simply need to
reinstall the newer version of FiftyOne and then follow these instructions.

See [this page](troubleshooting.md#troubleshooting-downgrades) if you need to install
FiftyOne v0.7.3 or earlier.

Note

If you are working with a
[custom/shared MongoDB database](../../fiftyone_concepts/config.md#configuring-mongodb-connection), you
can use [database admin privileges](../../fiftyone_concepts/config.md#database-migrations) to control
which clients are allowed to downgrade your FiftyOne deployment.

## Uninstalling FiftyOne [¶](\#uninstalling-fiftyone "Permalink to this headline")

FiftyOne and all of its subpackages can be uninstalled with:

```python
pip uninstall fiftyone fiftyone-brain fiftyone-db

```

