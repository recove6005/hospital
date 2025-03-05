import Busboy from 'busboy';

/**
 * @param {import('express').Request} req
 * @returns {Promise<{files: Array<{ fieldname: string, filename: string, buffer: Buffer, mimetype: string }>, fields: Object}>}
 */

export const parseFormData = (req) => {
    return new Promise((resolve, reject) => {
        const busboy = new Busboy({ headers: req.headers });

        const files = [];
        const fields = {};
        
        busboy.on("field", (filedname, value) => {
            fields[filedname] = value;
        });

        busboy.on("file", (fieldname, file, filename, encoding, mimetype) => {
            let fileBuffer = [];

            file.on("data", (chunk) => {
                fileBuffer.push(chunk);
            });

            file.on("end", () => {
                files.push({
                    fieldname,
                    filename,
                    buffer: Buffer.concat(fileBuffer),
                    mimetype,
                });
            });
        });

        busboy.on("finish", () => {
            resolve({ files, fields });
        });

        busboy.on("error", (error) => {
            reject(error);
        });

        if(req.rawBody) {
            busboy.end(req.rawBody);
        } else {
            reject(new Error("Missing rawBody in request."));
        }
    });
}