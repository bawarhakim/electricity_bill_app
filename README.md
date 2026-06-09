# ElectriCalc

**ElectriCalc** is a Flutter-based mobile application developed to estimate monthly electricity bills efficiently and accurately. The application enables users to calculate electricity costs based on energy consumption, apply rebate percentages, and maintain a history of previous calculations through local database storage.

## Project Information

| Item                    | Details                             |
| ----------------------- | ----------------------------------- |
| Project Name            | ElectriCalc                         |
| Platform                | Android                             |
| Framework               | Flutter                             |
| Programming Language    | Dart                                |
| Database                | SQLite (sqflite)                    |
| Development Environment | Android Studio / Visual Studio Code |

---

## Abstract

Managing household electricity expenses can be challenging without proper estimation tools. ElectriCalc was developed to provide users with a simple and efficient solution for calculating electricity bills based on monthly energy consumption. The application incorporates tariff calculations, rebate adjustments, and local data storage, allowing users to track and manage electricity expenses directly from their mobile devices.

---

## Objectives

The primary objectives of this project are:

* To develop a mobile application for electricity bill estimation.
* To provide accurate cost calculations based on energy consumption.
* To allow users to store and manage historical billing records.
* To implement local database functionality using SQLite.
* To demonstrate the application of Flutter in mobile software development.

---

## Features

### Electricity Bill Calculation

* Calculates monthly electricity costs based on user-entered kWh consumption.
* Supports tariff-based billing calculations.
* Provides instant calculation results.

### Rebate Management

* Allows users to apply rebate percentages.
* Automatically updates the final payable amount.

### History Management

* Save calculated bills to a local database.
* View previous calculation records.
* Edit existing records.
* Delete unwanted records.

### User-Friendly Interface

* Modern Material Design interface.
* Responsive and intuitive navigation.
* Easy-to-understand workflow.

---

## Technologies Used

### Front-End Development

* Flutter
* Dart

### Database

* SQLite
* sqflite Package

### Additional Packages

* path
* url_launcher
* cupertino_icons

---

## System Architecture

```text
User Interface (Flutter)
        │
        ▼
Business Logic Layer
        │
        ▼
SQLite Database (sqflite)
        │
        ▼
Stored Electricity Bill Records
```

---

## Installation Guide

### Prerequisites

* Flutter SDK (3.0 or later)
* Android Studio or Visual Studio Code
* Android Emulator or Physical Device

### Installation Steps

1. Clone the repository:

```bash
git clone https://github.com/bawarhakim/electricity_bill_app
```

2. Navigate to the project directory:

```bash
cd electricity_bill_app
```

3. Install required packages:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

---

## Application Workflow

1. Launch the application.
2. Navigate to the Calculator screen.
3. Select the billing month.
4. Enter electricity consumption in kilowatt-hours (kWh).
5. Adjust the rebate percentage if applicable.
6. Press the **Calculate** button.
7. Review the estimated electricity bill.
8. Save the calculation to the database.
9. Access the History screen to view, update, or delete records.

---

## Database Design

The application utilizes SQLite for local data storage.

### Stored Information

* Billing Month
* Electricity Usage (kWh)
* Total Charges
* Rebate Percentage
* Final Cost
* Record Date

---

## Future Enhancements

Future versions of ElectriCalc may include:

* PDF bill export functionality
* Data visualization and analytics charts
* Cloud synchronization
* Multi-country tariff support
* Dark mode support
* User authentication

---

## Developer

**Bawar Hakim**

Bachelor of Information Technology

Mobile Technology Course Project

Qaiwan International University

---

## License

This project was developed for academic and educational purposes. Unauthorized commercial distribution is not permitted without the developer's consent.

---

© 2026 Bawar Hakim. All Rights Reserved.
