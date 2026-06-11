# Lifeline Mesh

**AI-Powered Emergency Coordination & Medical Funding Infrastructure**

"From emergency to treatment — coordinated, funded, and delivered in real time."

---

## Overview

Lifeline Mesh is a production-grade cross-platform mobile and web platform that connects patients, family members, community supporters, drivers, hospitals, emergency moderators, and AI coordination systems in a real-time emergency response network.

### Target Regions
- **Primary Launch:** Ghana
- **Expansion:** West Africa → Africa-wide → Emerging economies globally

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Android, iOS, Web) |
| **Backend** | Supabase (PostgreSQL, Edge Functions, Realtime) |
| **State Management** | Riverpod |
| **Maps** | Google Maps + OpenStreetMap fallback |
| **Payments** | Moolre API + Mobile Money |
| **Auth** | OTP (Phone) + Role-based |
| **AI** | Edge Functions + External AI APIs |
| **Analytics** | PostHog / Firebase |
| **Storage** | Supabase Storage |

---

## Project Structure

```
lifeline_mesh/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── router/
│   │   ├── utils/
│   │   ├── widgets/
│   │   └── services/
│   ├── models/
│   │   └── enums/
│   ├── repositories/
│   ├── providers/
│   └── features/
│       ├── auth/
│       ├── emergency/
│       ├── family/
│       ├── community/
│       ├── driver/
│       ├── hospital/
│       ├── payments/
│       └── admin/
├── supabase/
│   ├── migrations/
│   ├── functions/
│   └── config.toml
└── assets/
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.27+
- Supabase CLI
- Dart SDK 3.6+

### Installation

1. Clone the repository
2. `flutter pub get`
3. Copy `.env.example` to `.env` and fill in credentials
4. Run Supabase locally: `supabase start`
5. Run migrations: `supabase db push`
6. Run the app: `flutter run`

---

## System Roles

1. **Patient** - Request emergency, track progress
2. **Family Member** - Receive alerts, contribute funds
3. **Community Supporter** - View campaigns, contribute
4. **Driver** - Accept requests, transport patients
5. **Hospital** - Receive emergencies, confirm readiness
6. **Moderator** - Review flagged emergencies
7. **Admin** - System-wide oversight

---

## Database

9 tables with Row-Level Security, triggers for `updated_at` and funding calculations, and indexes for performance. See `supabase/migrations/00001_initial_schema.sql`.

## Edge Functions

- `create-emergency` - AI triage + dispatch
- `process-contribution` - Moolre payment processing
- `fraud-detection` - Behavioral analysis
- `release-payment` - Escrow release
- `send-notification` - Multi-channel notifications

## Security

- RLS on all tables
- RBAC with 7 user roles
- OTP phone verification
- Full audit logging
- AI-powered fraud detection