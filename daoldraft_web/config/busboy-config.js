import Busboy from 'busboy';

/**
 * @param {import('express').Request} req
 * @returns {Promise<{files: Array<{ fieldname: string, filename: string, buffer: Buffer, mimetype: string }>, fields: Object}>}
 */

export const parseFormData = (req) => {
    return new Promise((resolve, reject) => {
        // 로컬 환경 rawBody 생성
        let requestBodyBuffer = [];
        req.on('data', (chunk) => {
            requestBodyBuffer.push(chunk);
        });

        req.on('end', () => {
            const finalBuffer = Buffer.concat(requestBodyBuffer);

            const busboy = new Busboy({
                headers: req.headers,
                defParamCharset: 'utf8', // 인코딩 문제 방지
                limits: { fileSize: 10 * 1024 * 1024 }, // 10MB 제한
            });

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

            busboy.end(req.rawBody || finalBuffer);
        });

        req.on("error", (error) => {
            reject(error);
        });
    });
}