import { get } from 'lodash'
import { create_invoice_schema } from "../schemas/create_invoice";
import { CreateInvoiceContext } from "./context";

export async function checksAvailabilityFields(context: CreateInvoiceContext): Promise<CreateInvoiceContext> {
    context.invoice = await create_invoice_schema.validateAsync(context.xml);

    return context
}

export function transformAndWriteInvoice(context: CreateInvoiceContext): CreateInvoiceContext {
    const payments: Record<string, unknown>[] = get(context.invoice, 'cfdi:Comprobante.cfdi:Conceptos.cfdi:Concepto', []) as Record<string, unknown>[]
    const payload: Record<string, any> = {
        'total': get(context.invoice, 'cfdi:Comprobante._attributes.Total'),
        'uuid': get(context.invoice, 'cfdi:Comprobante.cfdi:Complemento.tfd:TimbreFiscalDigital._attributes.UUID'),
        'fecha_timbrado': get(context.invoice, 'cfdi:Comprobante.cfdi:Complemento.tfd:TimbreFiscalDigital._attributes.FechaTimbrado'),
        'emisor': {
            'rfc': get(context.invoice, 'cfdi:Comprobante.cfdi:Emisor._attributes.Rfc'),
            'nombre': get(context.invoice, 'cfdi:Comprobante.cfdi:Emisor._attributes.Nombre'),
            'regimen_fiscal': get(context.invoice, 'cfdi:Comprobante.cfdi:Emisor._attributes.RegimenFiscal'),
        },
        'receptor': {
            'rfc': get(context.invoice, 'cfdi:Comprobante.cfdi:Receptor._attributes.Rfc'),
            'nombre': get(context.invoice, 'cfdi:Comprobante.cfdi:Receptor._attributes.Nombre'),
            'regimen_fiscal': get(context.invoice, 'cfdi:Comprobante.cfdi:Receptor._attributes.RegimenFiscalReceptor'),
        },
        'conceptos': payments.map((item) => ({
            'desccripcion': get(item, '_attributes.Descripcion'),
            'importe': get(item, '_attributes.Importe'),
        }))
    }

    context.res.json(payload)

    return context
}
