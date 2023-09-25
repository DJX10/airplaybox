const express = require("express");
const path = require("path")
const app = express();
const server = require('http').createServer(app)
const mqtt = require('mqtt');
const WebSocket = require('ws')

const ROOT_TOPIC = "test/";
const MQTT_SERVER = "mqtt://192.168.88.31:1883";
const MQTT_TOPICS = [ ROOT_TOPIC+"title", ROOT_TOPIC+"artist", ROOT_TOPIC+"album", ROOT_TOPIC+"play_end"];

const TRACK_TOPIC = ROOT_TOPIC+"title";
const ARTIST_TOPIC = ROOT_TOPIC+"artist";
const ALBUM_TOPIC = ROOT_TOPIC+"album";
const PLAY_END_TOPIC = ROOT_TOPIC+"play_end";


let count = 0;

const wss = new WebSocket.Server({ port:8888 });

let currentSong = "Not Playing";
let currentArtist = "";
let currentAlbum = "";
let serverActive = true;

app.use(express.static(path.join(__dirname, "public")));
let obj = {}

wss.on('connection', function connection(ws) {
    console.log('Client Connected')
    ws.send(JSON.stringify({'song':currentSong, 'artist':currentArtist, 'album':currentAlbum}));


    obj.sendSongInfo = function(songData){
        ws.send(JSON.stringify({'song':songData.currentSong, 'artist':songData.currentArtist, 'album':songData.currentAlbum}));
    }

});

async function startMQTT() {
    const client = mqtt.connect(MQTT_SERVER);

    client.on('connect', function () {
        console.log('connected to MQTT');
    });

    client.on("error",function(error){
        console.log("Can't connect" + error);
        process.exit(1)
    });

    client.subscribe(MQTT_TOPICS, {qos:0});

    client.on('message',async function(topic, message, packet){
        console.log("message is "+ message);
        console.log("topic is "+ topic);
        if (topic === TRACK_TOPIC){
            currentSong = message.toString();
            obj.sendSongInfo({'currentSong':currentSong, 'currentArtist':currentArtist, 'currentAlbum':currentAlbum});
        } else if (topic === ARTIST_TOPIC){
            currentArtist = message.toString();
            obj.sendSongInfo({'currentSong':currentSong, 'currentArtist':currentArtist, 'currentAlbum':currentAlbum});
        } else if (topic === ALBUM_TOPIC){
            currentAlbum = message.toString();
            obj.sendSongInfo({'currentSong':currentSong, 'currentArtist':currentArtist, 'currentAlbum':currentAlbum});
        } else if (topic === PLAY_END_TOPIC){
            console.log("Play ended")
            obj.sendSongInfo({'currentSong':"Not Playing", 'currentArtist':"", 'currentAlbum':""});
        }
    });

}

startMQTT();




app.get("/", (req, res) => {
    res.sendFile(path.join(__dirname,"views/index.html"))
});

app.get('/style.css', function(req, res) {
    res.sendFile(__dirname + "/public/css/" + "style.css");
});

app.get('/style.scss', function(req, res) {
    res.sendFile(__dirname + "/public/scss/" + "style.scss");
});


server.listen(5001, () => {
    console.log("server started on port 5001");
});


const sleep = (milliseconds) => {
    return new Promise(resolve => setTimeout(resolve, milliseconds))
}

