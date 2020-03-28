![CI](https://github.com/gvergine/com.systemassembly.sm.dsl.parent/workflows/CI/badge.svg)

# SmDsl
SmDsl is a state machine domain-specific language that comes with a code generator that produces MISRA-C 2012 compliant source code. The code generated does not have any dependencies.

# License
SmDsl is Free Software, released under GPLv3 license.

# Build instructions
```
git clone https://github.com/gvergine/com.systemassembly.sm.dsl.parent
cd com.systemassembly.sm.dsl.parent
mvn compile test package
```
# Example

Here is a comprehensive example of a blinking light system, that could be off (state `disabled`) or on. When the system is off, the light should be off, when the system is on, the light blinks (toggles between states `enabled_light_on` and `enabled_light_off`).
The events that make the state to change are `toggle` (to enable or disable the system) and `timeout`, that could be spawned by a periodic timer.
The commands that the user should fill in order the system to produce an effect are `turn_light_on` and `turn_light_off` (e.g. writing ones and zeros on a GPIO pin), `start_timer` and `stop_timer` (start and stop a system-dependent periodic timer).

Here is how `BlinkingLight.sm` could look like:

```
name BlinkingLight

events {
    toggle
    timeout
}

commands {
    turn_light_on
    turn_light_off
    start_timer
    stop_timer
}

initial state disabled {
    on entry {
        exec stop_timer
    }

    on toggle {
        goto enabled_light_on
    }

    on exit {
        exec start_timer
    }
}

state enabled_light_on {
    on entry {
        exec turn_light_on
    }

    on toggle {
        exec turn_light_off
        goto disabled
    }

    on timeout {
        goto enabled_light_off
    }
}

state enabled_light_off {
    on entry {
        exec turn_light_off
    }

    on toggle {
        goto disabled
    }

    on timeout {
        goto enabled_light_on
    }
}
```

As you may have noticed, each state can execute commands on entry, on exit and on events, using the keyword `exec`. It is possible to perform a state transition only on events, using the keyword `goto`.

One and only one of the states has to be marked `initial`.

# Build artifacts
* SmDsl Command Line tool
* SmDsl Eclipse Repository

