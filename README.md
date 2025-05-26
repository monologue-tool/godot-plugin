# Monologue Godot Plugin

![GitHub stars](https://img.shields.io/github/stars/monologue-tool/godot-plugin?style=flat-square) ![Latest Release](https://img.shields.io/github/v/release/monologue-tool/godot-plugin?style=flat-square) ![Godot Engine 4.x](https://img.shields.io/badge/Godot-4.x-blue?style=flat-square) ![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)

This repository provides the official Godot plugin for interpreting and executing dialogue files exported from the [Monologue dialogue editor](https://github.com/monologue-tool/monologue).
It is intended as a runtime companion for Monologue, allowing you to integrate authored dialogues into your Godot projects with minimal setup.

## Installation

1. Download or clone this repository.
2. Copy the `addons/monologue` folder into your Godot 4 project.
3. In the Godot editor, go to **Project > Project Settings > Plugins**, and enable the plugin named **Monologue**.

You can now use Monologue nodes and scripts directly inside your game scenes.

*Note: You can use the example project as a basis for your own project.*

## Usage

Begin by adding a `MonologueProcess` node to your main scene, then add a `MonologueSettings` node as a child of this node. Next, link your `MonologueSettings` node and the other layout elements to the `MonologueProcess` node by setting all the variables. Feel free to adjust the settings of the `MonologueSettings` node.

For the layout elements, use a `MonologueTextBox` for the text box, a `VBoxContainer` or `HBoxContainer` for the choice selector, a `TextureRect` or `Sprite2D` node for the background, and a `MonologueCharacterDisplayer` for the character displayer.

Finally, in your root node script, write something like:

```gdscript
extends Control


@onready var process: MonologueProcess = $MonologueProcess


func _ready() -> void:
    var timeline: MonologueTimeline = process.preload_timeline("res://path/to/dialogue.json")
    process.start_timeline(timeline)

```

*Note: Look at the example for a better understanding.*

## License

This project is licensed under the terms of the [MIT License](./LICENSE).
