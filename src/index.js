"use strict";

// this will instantiate the service worker
// bulk of the content of the service worker is in src/assets/service-worker.js
require("./js/sw-installer");

// import { Rollbar } from "./js/rollbar";

const cloudFunction = process.env.CLOUD_URL;
// from package.json (via webpack.config)
console.log("** VERSION **", VERSION);

require("./styles.scss");

const { Elm } = require("./Main");
const phase2 = "2020-11-01";

// CLOUD_URL or EMULATOR_URL
var app = Elm.Main.init({
    flags: {
        cloudFunction,
        version: VERSION,
        phase2,
    },
});

app.ports.toJs.subscribe((data) => {
    switch (data.tag) {
        case "LogRollbar":
            console.error(data.payload);
            // Rollbar.info({
            //     source: "elm",
            //     message: data.payload,
            // });
            break;
        case "LogConsole":
            console.log(data.payload);
            break;
        case "LogError":
            console.error(data.payload);
            break;
        default:
            console.error(data);
    }
});

// F i r e b a s e

// Set up Elm to use Firebase handler
import fb from "./Firebase/fb";

app.ports.elmToFb.subscribe((msg) =>
    fb.handler(msg, (val) => app.ports.fbToElm.send(val))
);
