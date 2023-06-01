# dita-to-pagedjs

The DITA plugins in this repository are nowhere near complete and are for non-production demonstration purposes only.

## Prereqs

**DITA-OT**
1. Download, unzip, and add it's `bin` folder to your path. (Tested with 4.0.2).
2. Add the full path to this `dita-plugins` folder to the DITA-OT `configuration/configuration.properties` file's plugin paths entry.
3. Run `dita install`.

**Paged.js**
1. Install NodeJS. (Tested with the latest v18 lts version.) Recommend using `nvm` to manage your NodeJS version installations.
2. Install Paged.js (with the CLI).
    ```
    npm install pagedjs-cli pagedjs
    ```

## Running the sample

The `docsrc` folder contains a Lorem ipsum book that these plugins were tested on.

(For debugging, I've been preserving the temp files.)

```bash
./build.sh -t ./tmp --clean.temp=no
```
