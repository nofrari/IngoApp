import { NextFunction, Request, Response } from "express";
import jwt from 'jsonwebtoken';

export default (req: Request, res: Response, next: NextFunction) => {
    const rawToken = req.header('authorization');

    if (!rawToken) {
        res.status(401).send();
        return;
    }

    const authHeaderParts = rawToken?.split(' ');
    const token = authHeaderParts[1];

    jwt.verify(token, <string>process.env.JWT_SECRET, (err, decoded) => {
        if (err || !decoded) {
            res.status(401).send();
            return;
        }

        res.locals.user = decoded;
        next();
    });
};
