import Joi from 'joi'

export const create_invoice_schema = Joi.object({
    'cfdi:Comprobante': Joi.object({
        '_attributes': Joi.object({
            'TipoDeComprobante': Joi.string().required().equal('I'),
            'Total': Joi.number().required(),
        }).required().unknown(),
        'cfdi:Complemento': Joi.object({
            'tfd:TimbreFiscalDigital': Joi.object({
                '_attributes': Joi.object({
                    'FechaTimbrado': Joi.date().iso().required(),
                    'UUID': Joi.string().uuid().required(),
                }).required().unknown(),
            }).required().unknown()
        }).required().unknown(),
        'cfdi:Emisor': Joi.object({}).required().unknown(),
        'cfdi:Receptor': Joi.object({}).required().unknown(),
    }).required().unknown(),
}).required().unknown()
