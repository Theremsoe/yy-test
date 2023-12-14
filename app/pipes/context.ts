import { Request, Response } from 'express'
import { ElementCompact } from 'xml-js';

export class CreateInvoiceContext {
    constructor(
        public readonly req: Request,
        public readonly res: Response,
        public xml: ElementCompact = {},
        public invoice: Record<string, unknown> = {}
    ) { }
}
