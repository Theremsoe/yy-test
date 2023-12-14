import { Request, Response, NextFunction } from 'express';
import { HttpError } from 'http-errors';
import Exception from './exception';


export default function errorHandler(
    error: Error,
    req: Request,
    res: Response,
    next: NextFunction): void {
    if (res.headersSent) {
        return next(error)
    }

    // I need fix: error instanceof ValidationError
    if (error.name === 'ValidationError') {
        const multiple: Record<string, any>[] = []

        // @ts-ignore
        for (const key in error.details) {
            multiple.push({
                'status': 422,
                'title': 'Unprocessable Entity',
                // @ts-ignore
                'source': { 'pointer': error.details[key].path.shift() },
                // @ts-ignore
                'detail': error.details[key].message,
            })
        }

        res.status(422);
        res.json({
            'errors': multiple,
        });

        return
    }

    if (error instanceof HttpError) {
        for (const key in error.headers) {
            res.setHeader(key, error.headers[key]);
        }

        res.status(error.statusCode);
        res.json({
            'errors': [{
                'status': error.statusCode,
                'title': error.name.replace(/([A-Z])/g, " $1"),
                'detail': error.message,
            }]
        });
    }

    if (error instanceof Exception) {
        res.status(409);
        res.json({
            'errors': [{
                'status': 409,
                'title': 'Conflict',
                'detail': error.message,
            }]
        });

        return;
    }

    res.status(500)
    res.json({
        'errors': [{
            'status': 500,
            'title': 'Internal server error',
            'detail': error.message,
        }]
    });
}
