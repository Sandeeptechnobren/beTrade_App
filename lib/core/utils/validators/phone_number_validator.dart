class Validators {
  static String? validatePhone(
      String phone, {
        String? countryCode,
      }) {
    if (phone.isEmpty) return "Phone number required";

    phone = phone.replaceAll(" ", "");

    switch (countryCode) {
      case "+91": // India
        if (phone.length != 10) return "Enter valid 10 digit number";
        break;

      case "+1": // USA
        if (phone.length != 10) return "Enter valid US number";
        break;

      case "+44": // UK
        if (phone.length < 10) return "Invalid UK number";
        break;

      default:
        if (phone.length < 6) return "Invalid phone number";
    }
    return null;
  }
}