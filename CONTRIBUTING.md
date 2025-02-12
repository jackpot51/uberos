# Contributing to Redox

**Thank you for your interest in contributing to Redox!**

This document will outline the basics of where to start if you wish to contribute to the project. There are many ways to help us out and and we appreciate all of them. We look forward to **your contribution!**

**Please read this document until the end**

## Code Of Conduct

We follow the [Rust Code Of Conduct](https://www.rust-lang.org/policies/code-of-conduct).

## License

In general, your contributions to Redox are governed by the [MIT License](https://en.wikipedia.org/wiki/MIT_License). Each project repository has a `LICENSE` file that provides the license terms for that project.

Please review the `LICENSE` file for the project you are contributing to.

[This](https://doc.redox-os.org/book/philosophy.html) page we explain why we use the MIT license.

## Chat

Join us on [Matrix Chat](https://doc.redox-os.org/book/chat.html) to discuss issues or ask questions.

## Important Places to Contribute

Before starting to contribute, we recommend reading the [Website FAQ](https://www.redox-os.org/faq/) and the [Redox Book](https://doc.redox-os.org/book/).

You can contribute to the Redox documentation and code on the following repositories (non-exhaustive, easiest first):

- [Website](https://gitlab.redox-os.org/redox-os/website)
- [Book](https://gitlab.redox-os.org/redox-os/book) - High-level documentation
- [Build System Configuration](https://gitlab.redox-os.org/redox-os/redox) - Our main repository
- [Cookbook](https://gitlab.redox-os.org/redox-os/cookbook) - Software Ports System
- [Orbital](https://gitlab.redox-os.org/redox-os/orbital) - Display Server and Window Manager
- [pkgutils](https://gitlab.redox-os.org/redox-os/pkgutils) - Package Manager
- [resist](https://gitlab.redox-os.org/redox-os/resist) - Redox System Interface Specifications and Tests (also has POSIX tests)
- [acid](https://gitlab.redox-os.org/redox-os/acid) - Redox Test Suite
- [relibc](https://gitlab.redox-os.org/redox-os/relibc) - Redox C Library
- [libredox](https://gitlab.redox-os.org/redox-os/libredox) - Redox System Library
- [netstack](https://gitlab.redox-os.org/redox-os/netstack) - Network Stack
- [Bootloader](https://gitlab.redox-os.org/redox-os/bootloader)
- [Drivers](https://gitlab.redox-os.org/redox-os/drivers) - Device Drivers
- [Kernel](https://gitlab.redox-os.org/redox-os/kernel)

To see all Redox repositories open the [redox-os group](https://gitlab.redox-os.org/redox-os).

### Skill Levels

If you don't know programming:

- Write documentation
- Use and test Redox, and file issues for bugs or needed features (please check for duplicates first etc.)

If you don't know how to code in Rust, but know other programming languages:

- Web development on the website (we don't accept JavaScript code)
- Write unit tests (may require minimal knowledge of Rust)
- Port C/C++ programs to Redox (read the `TODO`s of the recipes on the [WIP category](https://gitlab.redox-os.org/redox-os/cookbook/-/tree/master/recipes/wip?ref_type=heads))
- Port programs to Redox

If you know how to code in Rust, but don't know operating system development:

- Look for issues labeled "good first issue", "easy", and/or "help wanted", e.g. [this GitLab filter](https://gitlab.redox-os.org/groups/redox-os/-/issues/?sort=updated_desc&state=opened&or%5Blabel_name%5D%5B%5D=good%20first%20issue&or%5Blabel_name%5D%5B%5D=Easy&or%5Blabel_name%5D%5B%5D=easy&or%5Blabel_name%5D%5B%5D=help%20wanted&first_page_size=20]). Worth noting the skill level varies between projects, but a large subset of these should be approachable by contributors familiar with regular Rust/Unix application programming.
- Improve the package manager, or other meta-tools like `redoxer` or `installer`
- Improve the [Ion](https://gitlab.redox-os.org/redox-os/ion) shell, or other high-level or mid-level projects
- Port Rust programs to Redox, possibly including dependencies, and C library extensions if necessary (also look for issues with the `port` label)
- Improve program compatibility in relibc by e.g. implementing missing APIs

If you know how to code in Rust, and have experience with systems software/OS development:

- Familiarize yourself with the repository layout, code, and build system
- Update old code to remove warnings
- Search for `TODO`, `FIXME`, `BUG`, `UNOPTIMIZED`, `REWRITEME`, `DOCME`, and `PRETTYFYME` and fix the code you find
- Look in general for issues with the following labels: `critical`, `help wanted`, `feature`, `enhancement`, `bug` or `port`
- Improve internal libraries and abstractions, e.g. `libredox`, `redox-scheme`, `redox-event` etc.
- Help upstream Redox-specific functionality to the Rust ecosystem
- Improve Redox's automated testing suite and continuous integration testing processes
- Improve, profile, and optimize code, especially in the kernel, filesystem, and network stack
- Improve or write device drivers

For those who want to contribute to the Redox GUI, our GUI strategy has recently changed.

- We are improving the [Orbital](https://gitlab.redox-os.org/redox-os/orbital) display server and window manager, you can read more about it on [this tracking issue](https://gitlab.redox-os.org/redox-os/redox/-/issues/1430).
- Redox is in the process of adopting other Rust-written GUI toolkits, such as [Iced](https://iced.rs) and [Slint](https://slint-ui.com/). Please check out those projects if this is your area of interest.
- OrbTk is in maintenance mode, and its developers have moved to other projects such as the ones below. There is currently no Redox-specific GUI development underway.

## Priorities

You can use the following GitLab label filters to know our development priorities on the moment:

- [Critical](https://gitlab.redox-os.org/redox-os/redox/-/issues/?sort=created_date&state=opened&label_name%5B%5D=critical&first_page_size=20)
- [High-priority](https://gitlab.redox-os.org/redox-os/redox/-/issues/?sort=created_date&state=opened&label_name%5B%5D=high-priority&first_page_size=20)
- [Medium-priority](https://gitlab.redox-os.org/redox-os/redox/-/issues/?sort=created_date&state=opened&label_name%5B%5D=medium-priority&first_page_size=20)
- [Low-priority](https://gitlab.redox-os.org/redox-os/redox/-/issues/?sort=created_date&state=opened&label_name%5B%5D=low-priority&first_page_size=20)

## RFCs

For more significant changes that affect Redox's architecture, we use the [Request for Comments](https://gitlab.redox-os.org/redox-os/rfcs) repository.

## Build System

To download the build system use the following commands:

(You need to have [curl](https://curl.se/) installed on your system)

```sh
curl -sf https://gitlab.redox-os.org/redox-os/redox/raw/master/podman_bootstrap.sh -o podman_bootstrap.sh
```

```sh
time bash -e podman_bootstrap.sh
```

To start the compilation of the default recipes run the command below:

```sh
make all
```

In case your operating system does not use SELinux, you must set the `USE_SELINUX` to `0` when calling `make all`, otherwise you might experience errors:

```sh
make all USE_SELINUX=0
```

You can find the build system organization and commands on the [Build System](https://doc.redox-os.org/book/build-system-reference.html) page.

## Developer FAQ

You can see the most common questions and problems on the [Developer FAQ](https://doc.redox-os.org/book/developer-faq.html) page.

## Porting Software

You can read how to use the Cookbook recipe system to port applications on the [Porting Applications using Recipes](https://doc.redox-os.org/book/porting-applications.html) page.

## Libraries and APIs

You can read the [Libraries and APIs](https://doc.redox-os.org/book/libraries-apis.html) page to learn about the libraries and APIs used in Redox.

## Visual Studio Code (VS Code) Configuration

To learn how to configure your VS Code to do Redox development please read the information below the [Visual Studio Code Configuration](https://doc.redox-os.org/book/coding-and-building.html#visual-studio-code-configuration) section.

## Development Tips

You can find important tips on the [Development Tips](https://doc.redox-os.org/book/coding-and-building.html#development-tips) section.

## References

We maintain a list of wikis, articles and videos to learn Rust, OS development and computer science on the [References](https://doc.redox-os.org/book/references.html) page.

If you are skilled there's a possibility that they could improve your knowledge in some way.

## Best Practices and Guidelines

You can read the best practices and guidelines on the [Best practices and guidelines](https://doc.redox-os.org/book/best-practices.html) chapter.

## Style Guidelines

### Rust

Since **Rust** is a relatively small and new language compared to others like C and C++, there's really only one standard. Just follow the official Rust standards for formatting, and maybe run `rustfmt` on your changes, until we setup the CI system to do it automatically.

### Git

Please follow our [Git style](https://doc.redox-os.org/book/creating-proper-pull-requests.html) for pull requests.

## GitLab

### Identity

Once your GitLab account is created, you should add your Matrix or Discord username (the name after the `@` symbol) on the "About" section of your profile, that way we recognize you properly.

### Issues

To know how to create issues on the Redox GitLab, read the [Filing Issues](https://doc.redox-os.org/book/filing-issues.html) page.

Once you create an issue don't forget to post the link on the Dev or Support rooms of the chat, because the GitLab email notifications have distractions (service messages or spam) and most developers don't left their GitLab pages open to receive desktop notifications from the web browser (which require a custom setting to receive issue notifications).

By doing this you help us to pay attention to your issues and avoid them to be accidentally forgotten.

### Pull Requests

Please follow [our process](https://doc.redox-os.org/book/creating-proper-pull-requests.html) for creating proper pull requests.

## Other Ways to Contribute

If you aren't good on coding, but you still want to help keep the project going, you can contribute and support in a variety of ways! We'll try to find a way to use anything you have to offer. 

### Design

If you're a good designer, whether it's 2D graphics, 3D graphics, interfaces, web design, you can help. We need logos, UI design, UI skins, app icons, desktop backgrounds, etc.

- [Redox backgrounds](https://gitlab.redox-os.org/redox-os/backgrounds) - You can send your wallpapers on this repository.
- [Redox assets](https://gitlab.redox-os.org/redox-os/assets) - You can send your logos, icons and themes on this repository.

If you have questions about the graphic design, ask us on the [Chat](https://doc.redox-os.org/book/chat.html).

### Donate to Redox

If you are interested in donating to the Redox OS Nonprofit, you can find instructions on the [Donate](https://www.redox-os.org/donate/) page.
