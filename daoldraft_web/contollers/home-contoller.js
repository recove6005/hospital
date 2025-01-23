import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import axios from 'axios';

// __dirname 설정
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export const getHomePage = (req, res) => {
    res.sendFile(path.join(__dirname, '../public/html/home.html'));
};

export const getGeocord = async (req, res) => {
  dotenv.config();
  const apiId = process.env.API_ID;
  const apiKey = process.env.API_KEY;

  const { address } = req.query;
  console.log(address);
  const encodedAddress = encodeURIComponent(address);
  console.log(encodedAddress);
  try {
    const response = await axios.get(`https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode?query=${encodedAddress}`, {
      headers: {
        'x-ncp-apigw-api-key-id': apiId,
        'x-ncp-apigw-api-key': apiKey,
        'Accept': 'application/json',
      },
    });

    const result = await response.data;

    const x = result.addresses[0].x;
    const y = result.addresses[0].y;
    console.log(`x: ${x}, y: ${y}`);

    return res.status(200).json({ x: x, y : y});
  } catch(e) {
    console.error('Error during geocoding:', e.message);
    console.error('Error response data:', e.response?.data);
  }
}

export const getMap = async (req, res) => {
  dotenv.config();
  const apiId = process.env.API_ID;
  const apiKey = process.env.API_KEY;

  const { x, y } = req.body;

  try {    
    const url = `https://naveropenapi.apigw.ntruss.com/map-static/v2/raster?w=300&h=300&center=${x},${y}&level=16&scale=2&format=png&lang=ko&markers=type:d|size:small|pos:${x}%20${y}`;
    const response = await axios.get(url, {
      headers: {
        'x-ncp-apigw-api-key-id': apiId,
        'x-ncp-apigw-api-key': apiKey,
      },
      responseType: 'arraybuffer',
    });

    res.setHeader('Content-Type', 'image/png');
    return res.status(200).send(Buffer.from(response.data, 'binary'));
  } catch (e) {
    console.error('Error details:', e.response?.data?.toString('utf8'));
    return res.status(500).json(`error: ${e.message}`);
  }
}
