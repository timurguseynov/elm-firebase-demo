// unneeded as this is added (albeit version 4.1.3) by webpack when properly configured
// importScripts(
//     "https://storage.googleapis.com/workbox-cdn/releases/5.1.2/workbox-sw.js"
// );

// Doesn't work - error: "can't import module"
// import { precacheAndRoute } from "workbox-precaching";
if (workbox) {
    console.log(`Setting up cache 🎉`);
    // The precache manifest lists the names of the files that were processed by webpack and that end up in your dist folder.
    workbox.precaching.precacheAndRoute(self.__precacheManifest);

    addEventListener("message", (event) => {
        // console.log("[service-worker.js] message", event.data);
        if (event.data && event.data.type === "SKIP_WAITING") {
            skipWaiting();
        }
    });
} else {
    console.log(`Hmm! Workbox didn't load 😬`);
}
