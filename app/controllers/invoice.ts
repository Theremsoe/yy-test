import { Request, Response } from 'express';
import Pipeline from "pipescript-ts"
import { parseXmlDocument, checksIsXmlDocument } from '../pipes/xml';
import { CreateInvoiceContext } from '../pipes/context';
import { checksAvailabilityFields, transformAndWriteInvoice } from '../pipes/invoice';

export async function create(req: Request, res: Response): Promise<void> {
    const pipe = new Pipeline([
        checksIsXmlDocument,
        parseXmlDocument,
        checksAvailabilityFields,
        transformAndWriteInvoice,
    ])

    const payload = new CreateInvoiceContext(req, res)

    await pipe.execute(payload)
}
