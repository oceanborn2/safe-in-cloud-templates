import xml.etree.ElementTree as ET
from lxml import etree
import base64
import datetime
import uuid
import subprocess
import logging

class Converter:
    def __init__(self):
        logging.basicConfig(level=logging.INFO)
        logging.getLogger("converter").setLevel(logging.WARNING)
        logging.info("Converter started.")

    def run(self):
        pass

#!/usr/bin/env python3
"""
SafeInCloud to KeePass XML Converter
Converts SafeInCloud XML exports to KeePass XML format
"""

import xml.etree.ElementTree as ET
from lxml import etree
import base64
import datetime
import uuid
import argparse
import os

class SafeInCloudToKeePassConverter:
    def __init__(self):
        self.groups = {}
        self.entries = []

    def parse_safeincloud_xml(self, xml_file):
        """Parse SafeInCloud XML export file"""
        tree = ET.parse(xml_file)
        root = tree.getroot()

        # Process labels first to create group mapping
        for label in root.findall('label'):
            label_id = label.get('id')
            label_name = label.get('name', 'Uncategorized')
            self.groups[label_id] = label_name

        # Process cards (entries)
        for card in root.findall('card'):
            if self._should_skip_card(card):
                continue

            entry = self._convert_card_to_entry(card)
            self.entries.append(entry)

    def _should_skip_card(self, card):
        """Skip deleted, template, or sample cards"""
        return (card.get('deleted') == 'true' or
                card.get('template') == 'true')

    def _convert_card_to_entry(self, card):
        """Convert SafeInCloud card to KeePass entry format"""
        entry = {
            'uuid': self._generate_uuid(),
            'title': card.get('title', 'Untitled'),
            'notes': card.find('notes').text if card.find('notes') is not None else '',
            'creation_time': datetime.datetime.now().isoformat(),
            'fields': {},
            'group': self._get_card_group(card)
        }

        # Process fields
        for field in card.findall('field'):
            field_name = field.get('name')
            field_type = field.get('type')
            field_value = field.text or ''

            # Map SafeInCloud field types to KeePass standard fields
            if field_type == 'login':
                entry['fields']['UserName'] = field_value
            elif field_type == 'password':
                entry['fields']['Password'] = field_value
            elif field_type == 'email':
                entry['fields']['URL'] = f"mailto:{field_value}"
            else:
                entry['fields'][field_name] = field_value

        return entry

    def _get_card_group(self, card):
        """Determine group for card based on label_id"""
        label_ids = [int(lid.text) for lid in card.findall('label_id') if lid.text]
        if label_ids:
            return self.groups.get(str(label_ids[0]), 'General')
        return 'General'

    def _generate_uuid(self):
        """Generate base64-encoded UUID for KeePass"""
        return base64.b64encode(uuid.uuid4().bytes).decode('utf-8')

    def generate_keepass_xml(self, output_file):
        """Generate KeePass XML format"""
        # Create root structure
        root = ET.Element('KeePassFile')

        # Add metadata
        meta = ET.SubElement(root, 'Meta')
        ET.SubElement(meta, 'Generator').text = 'SafeInCloud Converter'
        ET.SubElement(meta, 'DatabaseName').text = 'Converted from SafeInCloud'
        ET.SubElement(meta, 'DatabaseDescription').text = 'Imported from SafeInCloud XML'
        ET.SubElement(meta, 'DefaultUserName').text = ''
        ET.SubElement(meta, 'MaintenanceHistoryDays').text = '365'
        ET.SubElement(meta, 'Color').text = ''
        ET.SubElement(meta, 'MasterKeyChanged').text = datetime.datetime.now().isoformat()
        ET.SubElement(meta, 'MasterKeyChangeRec').text = '-1'
        ET.SubElement(meta, 'MasterKeyChangeForce').text = '-1'
        ET.SubElement(meta, 'RecycleBinEnabled').text = 'True'
        ET.SubElement(meta, 'RecycleBinUUID').text = self._generate_uuid()
        ET.SubElement(meta, 'RecycleBinChanged').text = datetime.datetime.now().isoformat()
        ET.SubElement(meta, 'EntryTemplatesGroup').text = self._generate_uuid()
        ET.SubElement(meta, 'EntryTemplatesGroupChanged').text = datetime.datetime.now().isoformat()
        ET.SubElement(meta, 'HistoryMaxItems').text = '10'
        ET.SubElement(meta, 'HistoryMaxSize').text = '6291456'
        ET.SubElement(meta, 'LastSelectedGroup').text = self._generate_uuid()
        ET.SubElement(meta, 'LastTopVisibleGroup').text = self._generate_uuid()

        # Add memory protection settings
        mem_prot = ET.SubElement(meta, 'MemoryProtection')
        ET.SubElement(mem_prot, 'ProtectTitle').text = 'False'
        ET.SubElement(mem_prot, 'ProtectUserName').text = 'False'
        ET.SubElement(mem_prot, 'ProtectPassword').text = 'True'
        ET.SubElement(mem_prot, 'ProtectURL').text = 'False'
        ET.SubElement(mem_prot, 'ProtectNotes').text = 'False'

        # Create root group structure
        root_elem = ET.SubElement(root, 'Root')
        root_group = ET.SubElement(root_elem, 'Group')
        ET.SubElement(root_group, 'UUID').text = self._generate_uuid()
        ET.SubElement(root_group, 'Name').text = 'Root'
        ET.SubElement(root_group, 'Notes').text = ''
        ET.SubElement(root_group, 'IconID').text = '48'

        # Add times
        times = ET.SubElement(root_group, 'Times')
        current_time = datetime.datetime.now().isoformat()
        ET.SubElement(times, 'CreationTime').text = current_time
        ET.SubElement(times, 'LastModificationTime').text = current_time
        ET.SubElement(times, 'LastAccessTime').text = current_time
        ET.SubElement(times, 'LocationChanged').text = current_time
        ET.SubElement(times, 'ExpiryTime').text = current_time
        ET.SubElement(times, 'Expires').text = 'False'
        ET.SubElement(times, 'UsageCount').text = '0'

        ET.SubElement(root_group, 'IsExpanded').text = 'True'
        ET.SubElement(root_group, 'DefaultAutoTypeSequence').text = ''
        ET.SubElement(root_group, 'EnableAutoType').text = 'null'
        ET.SubElement(root_group, 'EnableSearching').text = 'null'
        ET.SubElement(root_group, 'LastTopVisibleEntry').text = self._generate_uuid()

        # Group entries by category
        grouped_entries = {}
        for entry in self.entries:
            group_name = entry['group']
            if group_name not in grouped_entries:
                grouped_entries[group_name] = []
            grouped_entries[group_name].append(entry)

        # Create groups and entries
        for group_name, group_entries in grouped_entries.items():
            group_elem = ET.SubElement(root_group, 'Group')
            ET.SubElement(group_elem, 'UUID').text = self._generate_uuid()
            ET.SubElement(group_elem, 'Name').text = group_name
            ET.SubElement(group_elem, 'Notes').text = ''
            ET.SubElement(group_elem, 'IconID').text = '0'

            # Add group times
            group_times = ET.SubElement(group_elem, 'Times')
            ET.SubElement(group_times, 'CreationTime').text = current_time
            ET.SubElement(group_times, 'LastModificationTime').text = current_time
            ET.SubElement(group_times, 'LastAccessTime').text = current_time
            ET.SubElement(group_times, 'LocationChanged').text = current_time
            ET.SubElement(group_times, 'ExpiryTime').text = current_time
            ET.SubElement(group_times, 'Expires').text = 'False'
            ET.SubElement(group_times, 'UsageCount').text = '0'

            ET.SubElement(group_elem, 'IsExpanded').text = 'True'
            ET.SubElement(group_elem, 'DefaultAutoTypeSequence').text = ''
            ET.SubElement(group_elem, 'EnableAutoType').text = 'null'
            ET.SubElement(group_elem, 'EnableSearching').text = 'null'
            ET.SubElement(group_elem, 'LastTopVisibleEntry').text = self._generate_uuid()

            # Add entries to group
            for entry in group_entries:
                self._add_entry_to_group(group_elem, entry)

        # Write XML file
        tree = ET.ElementTree(root)
        ET.indent(tree, space="  ", level=0)
        tree.write(output_file, encoding='utf-8', xml_declaration=True)

    def _add_entry_to_group(self, group_elem, entry):
        """Add individual entry to group"""
        entry_elem = ET.SubElement(group_elem, 'Entry')
        ET.SubElement(entry_elem, 'UUID').text = entry['uuid']
        ET.SubElement(entry_elem, 'IconID').text = '0'
        ET.SubElement(entry_elem, 'ForegroundColor').text = ''
        ET.SubElement(entry_elem, 'BackgroundColor').text = ''
        ET.SubElement(entry_elem, 'OverrideURL').text = ''
        ET.SubElement(entry_elem, 'Tags').text = ''

        # Add times
        times = ET.SubElement(entry_elem, 'Times')
        current_time = datetime.datetime.now().isoformat()
        ET.SubElement(times, 'CreationTime').text = current_time
        ET.SubElement(times, 'LastModificationTime').text = current_time
        ET.SubElement(times, 'LastAccessTime').text = current_time
        ET.SubElement(times, 'LocationChanged').text = current_time
        ET.SubElement(times, 'ExpiryTime').text = current_time
        ET.SubElement(times, 'Expires').text = 'False'
        ET.SubElement(times, 'UsageCount').text = '0'

        # Add standard fields
        standard_fields = {
            'Title': entry['title'],
            'UserName': entry['fields'].get('UserName', ''),
            'Password': entry['fields'].get('Password', ''),
            'URL': entry['fields'].get('URL', ''),
            'Notes': entry['notes']
        }

        for key, value in standard_fields.items():
            string_elem = ET.SubElement(entry_elem, 'String')
            ET.SubElement(string_elem, 'Key').text = key
            value_elem = ET.SubElement(string_elem, 'Value')
            value_elem.text = value
            if key == 'Password':
                value_elem.set('Protected', 'True')

        # Add custom fields
        for field_name, field_value in entry['fields'].items():
            if field_name not in standard_fields:
                string_elem = ET.SubElement(entry_elem, 'String')
                ET.SubElement(string_elem, 'Key').text = field_name
                ET.SubElement(string_elem, 'Value').text = field_value

        # Add AutoType
        autotype = ET.SubElement(entry_elem, 'AutoType')
        ET.SubElement(autotype, 'Enabled').text = 'True'
        ET.SubElement(autotype, 'DataTransferObfuscation').text = '0'
        ET.SubElement(autotype, 'DefaultSequence').text = ''

        # Add History
        ET.SubElement(entry_elem, 'History')

def main():
    parser = argparse.ArgumentParser(description='Convert SafeInCloud XML to KeePass XML format')
    parser.add_argument('input_file', help='SafeInCloud XML export file')
    parser.add_argument('output_file', help='Output KeePass XML file')
    parser.add_argument('--create-binary', action='store_true',
                        help='Create binary KDBX file using KeePassXC CLI')
    parser.add_argument('--password', help='Password for binary database')

    args = parser.parse_args()

    # Convert XML
    converter = SafeInCloudToKeePassConverter()
    converter.parse_safeincloud_xml(args.input_file)
    converter.generate_keepass_xml(args.output_file)

    print(f"Converted {len(converter.entries)} entries to {args.output_file}")

    # Optionally create binary format
    if args.create_binary:
        create_binary_database(args.output_file, args.password)

if __name__ == '__main__':
    main()
