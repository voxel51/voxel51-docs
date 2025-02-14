# Plugins Overview [¶](\#plugins-overview "Permalink to this headline")

FiftyOne provides a powerful plugin framework that allows for extending and
customizing the functionality of the tool to suit your specific needs.

With plugins, you can add new functionality to the FiftyOne App, create
integrations with other tools and APIs, render custom panels, and add custom
actions to menus.

With [FiftyOne Teams](../teams/teams_plugins.md#teams-delegated-operations), you can even write
plugins that allow users to execute long-running tasks from within the App that
run on a connected compute cluster.

Get started with plugins by installing some
[popular plugins](#plugins-getting-started), then try your hand at
[writing your own](developing_plugins.md#developing-plugins)!

Note

Check out the
[FiftyOne plugins](https://github.com/voxel51/fiftyone-plugins)
repository for a growing collection of plugins that you can easily
[download](using_plugins.md#plugins-download) and use locally.

## Getting started [¶](\#getting-started "Permalink to this headline")

What can plugins do for you? Get started by installing any of
these plugins available in the
[FiftyOne Plugins](https://github.com/voxel51/fiftyone-plugins) repository:

|     |     |
| --- | --- |
| [@voxel51/annotation](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/annotation/README.md) | ✏️ Utilities for integrating FiftyOne with annotation tools |
| [@voxel51/brain](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/brain/README.md) | 🧠 Utilities for working with the FiftyOne Brain |
| [@voxel51/dashboard](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/dashboard/README.md) | 📊 Create your own custom dashboards from within the App |
| [@voxel51/evaluation](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/evaluation/README.md) | ✅ Utilities for evaluating models with FiftyOne |
| [@voxel51/io](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/io/README.md) | 📁 A collection of import/export utilities |
| [@voxel51/indexes](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/indexes/README.md) | 📈 Utilities for working with FiftyOne database indexes |
| [@voxel51/runs](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/runs/README.md) | 📈 Utilities for working with custom runs |
| [@voxel51/utils](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/utils/README.md) | ⚒️ Call your favorite SDK utilities from the App |
| [@voxel51/voxelgpt](https://github.com/voxel51/voxelgpt) | 🤖 An AI assistant that can query visual datasets, search the FiftyOne docs, and answer general computer vision questions |
| [@voxel51/zoo](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/zoo/README.md) | 🌎 Download datasets and run inference with models from the FiftyOne Zoo, all without leaving the App |

For example, do you wish you could import data from within the App? With the
[@voxel51/io](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/io/README.md),
plugin, you can!

![../../_images/import.webp](../../_images/import.webp)

Want to send data for annotation from within the App? Sure thing! Just install the
[@voxel51/annotation](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/annotation/README.md)
plugin:

![../../_images/annotation.webp](../../_images/annotation.webp)

Have model predictions on your dataset that you want to evaluate? The
[@voxel51/evaluation](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/evaluation/README.md)
plugin makes it easy:

![../../_images/evaluation.webp](../../_images/evaluation.webp)

Need to compute embedding for your dataset? Kick off the task with the
[@voxel51/brain](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/brain/README.md)
plugin and proceed with other work while the execution happens in the background:

![../../_images/embeddings.webp](../../_images/embeddings.webp)

Want to create a custom dashboard that displays statistics of interest about
the current dataset? Just install the
[@voxel51/dashboard](https://github.com/voxel51/fiftyone-plugins/blob/main/plugins/dashboard/README.md)
plugin and build away:

![../../_images/dashboard-panel.webp](../../_images/dashboard-panel.webp)

Note

When you choose [delegated execution](using_plugins.md#delegated-operations) in the
App, these tasks are automatically scheduled for execution on your
[connected orchestrator](using_plugins.md#delegated-orchestrator) and you can continue
with other work!

FiftyOne also includes a number of builtin features that are implemented as
plugins. For example, [Panels](developing_plugins.md#plugins-design-panels) are miniature
full-featured data applications that you can open in
[App Spaces](../fiftyone_concepts/app.md#app-spaces) and interactively manipulate to explore your
dataset and update/respond to updates from other spaces that are currently open
in the App.

Does your dataset have geolocation data? Use the
[Map panel](../fiftyone_concepts/app.md#app-map-panel) to view it:

![../../_images/app-map-panel.webp](../../_images/app-map-panel.webp)

Want to [visualize embeddings](../fiftyone_concepts/brain.md#brain-embeddings-visualization) in the
App? Just open the [Embeddings panel](../fiftyone_concepts/app.md#app-embeddings-panel):

![../../_images/brain-object-visualization.webp](../../_images/brain-object-visualization.webp)

Note

Look interesting? Learn how to [develop your own](developing_plugins.md#developing-plugins)
plugins!
