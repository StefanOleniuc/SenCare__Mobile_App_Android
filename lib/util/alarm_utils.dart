// lib/util/alarm_utils.dart
bool esteAlarma(num valoare, num min, num max) => valoare < min || valoare > max;

bool esteAvertizare(num valoare, num min, num max, {num delta = 2}) =>
    (valoare >= min && valoare < min + delta) || (valoare <= max && valoare > max - delta);