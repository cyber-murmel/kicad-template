#!/usr/bin/env python3
# coding=utf8

from argparse import ArgumentParser, FileType, ArgumentTypeError
from xml.etree import ElementTree
from csv import DictWriter, QUOTE_ALL


def parse_arguments():
    parser = ArgumentParser(
        description="Convert kicad-cli python-bom to csv", epilog=""
    )

    parser.add_argument(
        "-b", "--bom", required=True, type=FileType("r"), help="path to BOM input file"
    )
    parser.add_argument(
        "-c", "--csv", required=True, type=FileType("w"), help="path to BOM output file"
    )

    args = parser.parse_args()
    return args


def find_property(element, name):
    for prop in element.findall("property"):
        if name == prop.attrib["name"]:
            return prop


def get_property(element, name):
    prop = find_property(element, name)
    if None != prop:
        return prop.attrib["value"]


def main():
    args = parse_arguments()

    bom = ElementTree.fromstring(args.bom.read())
    args.bom.close()

    fieldnames = [
        "Designator",
        "Footprint",
        "Quantity",
        "Value",
        "LCSC Part #",
    ]
    writer = DictWriter(args.csv, fieldnames=fieldnames, quoting=QUOTE_ALL)
    writer.writeheader()

    grouped_bom = {}

    for component in bom.find("components"):
        if not find_property(component, "dnp"):
            ref = component.attrib["ref"]
            footprint = component.find("footprint").text
            value = component.find("value").text
            lcsc = get_property(component, "LCSC")

            fields = (footprint, value, lcsc)

            if not fields in grouped_bom:
                grouped_bom[fields] = [ref]
            else:
                grouped_bom[fields] += [ref]

    for fields, refs in grouped_bom.items():
        writer.writerow(
            {
                "Designator": ",".join(refs),
                "Footprint": fields[0],
                "Quantity": len(refs),
                "Value": fields[1],
                "LCSC Part #": fields[2],
            }
        )

    args.csv.close()


if "__main__" == __name__:
    main()
