import express from "express";
import getImage from "./getImageUrl.js";

const app = express();

app.get("/rasbign", async (req, res) => {
  const prompt = req.query.prompt;
  const url = await getImage(prompt);
  res.send(url);
});

app.listen(8080);
