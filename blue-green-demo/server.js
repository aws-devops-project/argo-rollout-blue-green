const express = require("express");
const path = require("path");

const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.static("public"));

app.get("/api/info", (req, res) => {

    res.json({

        environment: process.env.ENVIRONMENT,

        version: process.env.VERSION,

        pod: process.env.POD_NAME,

        node: process.env.NODE_NAME,

        podIP: process.env.POD_IP,

        hostname: process.env.HOSTNAME,

        region: process.env.REGION,

        time: new Date()

    });

});

app.listen(PORT, () => {

    console.log(`Server running on ${PORT}`);

});