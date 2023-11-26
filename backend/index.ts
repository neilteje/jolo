import { createClient } from "@supabase/supabase-js";
import cors from "cors";
import { config } from "dotenv";
import express, { NextFunction, Request, Response } from "express";
import fileUpload from "express-fileupload";

config();
const app = express();
app.use(fileUpload());
app.use(cors());

const supabase = createClient(
  process.env.SUPABASE_URL as string,
  process.env.SUPABASE_SERVICE_ROLE as string
);

const checkAuth = async (req: Request, res: Response, next: NextFunction) => {
  const jwt = req.headers.authorization?.split(" ")[1];
  if (!jwt) return res.status(401).send("Unauthorized");

  const { data } = await supabase.auth.getUser(jwt);

  if (!data) return res.status(401).send("Unauthorized");
  req.body.userId = data.user?.id;
  next();
};

app.post("/upload", checkAuth, async (req, res) => {
  try {
    if (!req.files) return res.status(400).send("No files were uploaded.");

    const audio = req.files["audio"] as fileUpload.UploadedFile;
    if (!audio || !audio.mimetype.startsWith("audio"))
      return res.status(400).send("No audio file was uploaded.");

    const { data, error } = await supabase.storage
      .from("recordings")
      .upload(`recording-${Date.now()}.${audio.name.split(".").pop()}`, audio.data);

    if (error) {
      console.error(error);
      return res.status(500).send("Error uploading file.");
    } else {
      await supabase.from("recordings").insert([{ filename: data.path, userId: req.body.userId }]);
      return res.status(200).send("File uploaded successfully.");
    }
  } catch (err) {
    console.error(err);
  }
});

app.get("/list", checkAuth, async (req, res) => {
  const { data } = await supabase
    .from("recordings")
    .select("*")
    .filter("userId", "eq", req.body.userId);

  return data;
});

app.listen(process.env.PORT || 5000, () => {
  console.log(`Server running on http://localhost:${process.env.PORT || 5000}`);
});
