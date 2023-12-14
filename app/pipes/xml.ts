import { xml2js } from "xml-js";
import { UnprocessableEntity } from 'http-errors'
import { CreateInvoiceContext } from "./context";

export function checksIsXmlDocument(context: CreateInvoiceContext): CreateInvoiceContext {
    if (!context.req.file || context.req.file.mimetype !== 'application/xml') {
        throw new UnprocessableEntity('Required "invoice" file field must be xml format')
    }

    return context
}

export async function parseXmlDocument(context: CreateInvoiceContext): Promise<CreateInvoiceContext> {
    if (!context.req.file || !context.req.file.size) {
        throw new UnprocessableEntity('Required "invoice" file field is empty')
    }

    context.xml = xml2js(context.req.file.buffer.toString('utf8'), { compact: true, })

    return context
}
