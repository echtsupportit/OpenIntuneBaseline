# Assignment Model

## Deployment Rings

| Ring | Group Name | Purpose |
|---|---|---|
| Ring 0 | INTUNE-EIT-OIB-LAB | Lab/test devices |
| Ring 1 | INTUNE-EIT-OIB-PILOT | IT pilot devices/users |
| Ring 2 | INTUNE-EIT-OIB-BUSINESS-PILOT | Friendly-user pilot |
| Ring 3 | INTUNE-EIT-OIB-PROD | Production deployment |
| Exclusion | INTUNE-EIT-OIB-EXCLUDE | General exclusions |
| Break Glass | INTUNE-EIT-OIB-BREAKGLASS-EXCLUDE | Emergency/break-glass exclusions |

## Rules

- Never assign a new baseline directly to production.
- Start with Ring 0.
- Move to Ring 1 only after validation.
- Move to Ring 2 only after IT pilot approval.
- Move to Ring 3 only after customer approval.
- Keep break-glass accounts/devices excluded where applicable.
