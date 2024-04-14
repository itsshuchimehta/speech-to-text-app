var recognition = new webkitSpeechRecognition();
recognition.continuous = true;

recognition.onresult = function (event) {
  var last = event.results.length - 1;
  var transcript = event.results[last][0].transcript;
  app.ports.receiveTranscription.send(transcript);
};

recognition.onerror = function (event) {
  app.ports.receiveTranscription.send("Error: " + event.error);
};

app.ports.startListeningCmd.subscribe(function (language) {
  recognition.lang = language;
  recognition.start();
});

app.ports.stopListeningCmd.subscribe(function () {
  recognition.stop();
});
