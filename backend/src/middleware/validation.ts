import { Request, Response, NextFunction } from "express";
import Joi from "joi";

// Validation middleware
export const validateRequest = (schema: Joi.ObjectSchema) => {
    return (req: Request, res: Response, next: NextFunction): void => {
      const { error } = schema.validate(req.body);
      if (error) {
        res.status(400).json({
          success: false,
          error: error.details[0].message
        });
        return; // ✅ просто return, без возврата Response
      }
      next();
    };
  };
  