# EasyShop Design Tokens

Values taken from the Admin Figma design. The code lives in `lib/core/theme/`. If you change a value here, change it in the code too.

## Colors (`app_color.dart`)

### Brand

| Name | Value | Used for |
|---|---|---|
| `primary` | `#F5821F` | Admin buttons, links, selected tab, focused field border |
| `primaryLight` | `#F6BD8D` | Disabled button background |
| `primarySoft` | `#FFF4EC` | Soft orange backgrounds (outlined button, icon circles) |

Note: the Client design uses a different orange, about `#FF6900`. It will be added when the Client app starts.

### Light mode

| Name | Value | Used for |
|---|---|---|
| `background` | `#F7F8FA` | Screen background |
| `surface` | `#FFFFFF` | Cards, top bar, bottom navigation |
| `inputBackground` | `#F2F2F7` | Text field fill |
| `textPrimary` | `#1A1A28` | Main text |
| `textSecondary` | `#8A8A9E` | Hints, small gray text |
| `border` | `#E5E5EC` | Field borders, dividers |

### Dark mode

| Name | Value |
|---|---|
| `darkBackground` | `#121318` |
| `darkSurface` | `#1C1D25` |
| `darkInputBackground` | `#252631` |
| `darkTextPrimary` | `#F5F5F7` |
| `darkTextSecondary` | `#B1B2C0` |
| `darkBorder` | `#383945` |

### Status

| Name | Color | Light background | Dark background |
|---|---|---|---|
| Success | `#0F9F6F` | `#ECFDF5` | `#16352B` |
| Warning | `#D97706` | `#FFFBEB` | `#3B2D16` |
| Error | `#DC2626` | `#FEF2F2` | `#3B2023` |
| Info | `#155DFC` | `#EFF6FF` | `#1B2D4A` |

## Text (`app_text_styles.dart`)

Font family: Flutter default (not set yet).

| Style | Size | Weight | Used for |
|---|---|---|---|
| `headlineLarge` | 32 | 700 | Big titles |
| `headlineMedium` | 24 | 600 | Section titles |
| `titleLarge` | 20 | 600 | Screen titles |
| `titleMedium` | 16 | 600 | Card titles, top bar title |
| `bodyLarge` | 16 | 400 | Main body text |
| `bodyMedium` | 14 | 400 | Normal text, field labels |
| `bodySmall` | 12 | 400 | Small gray text |
| `labelLarge` | 16 | 600 | Button text |

## Spacing (`app_spacing.dart`)

| Name | Value |
|---|---|
| `xs` | 4 |
| `sm` | 8 |
| `md` | 12 |
| `lg` | 16 |
| `xl` | 20 |
| `xxl` | 24 |
| `xxxl` | 32 |

## Corner radius (`app_radius.dart`)

| Name | Value | Used for |
|---|---|---|
| `sm` | 8 | Small chips |
| `md` | 12 | Buttons, fields, cards |
| `lg` | 16 | Big cards |
| `full` | 999 | Circles and pills |

## Sizes (`app_sizes.dart`)

| Name | Value | Used for |
|---|---|---|
| `iconSm` | 18 | Icon inside a button |
| `iconMd` | 20 | Back arrow |
| `iconLg` | 24 | Normal icons |
| `iconXl` | 64 | Empty and error state icons |
| `buttonHeight` | 52 | All main buttons |
| `loaderSm` | 20 | Loader inside a button |
| `loaderStroke` | 2 | Loader line width |
