# Remove Duplicate Calendar Events

Sometimes the calendar apps in macOS and iOS show duplicates of some of your events. This utility removes the duplicates. For any events in a calendar with identical identifies, it removes all but one. The utility ignores events with recurrences.

## Usage

To show which calendar events would be removed, from Terminal run:

``` zsh
./rdce
```

To actually remove duplicate calendar events, from Terminal run:

``` zsh
./rdce --remove
```
