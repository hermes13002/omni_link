{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    // Remove the HTML loader once Flutter engine is initialized
    const loader = document.getElementById('loading-indicator');
    if (loader) {
      loader.remove();
    }
    await appRunner.runApp();
  }
});
