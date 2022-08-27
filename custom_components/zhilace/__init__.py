import os
from functools import partial
from homeassistant.util import slugify
from homeassistant.util.yaml import load_yaml, save_yaml

sensor_units = ['°C', '%', 'µg/m³', 'ppm', 'mg/m³', 'lm']
# sensor_classes = ['temperature', 'humidity', 'pm25', 'co2', 'hcho', 'illuminance']
binary_sensor_classes = ['opening', 'motion', 'window', 'illuminance']
card_types = ['weather-forecast', 'glance', 'entities', 'entity', 'media-control', 'thermostat', 'picture-entity']
zone_names = [['客厅', '室内'], ['餐厅', '入户', '玄关', '厨房'], ['过道', '洗手间'], ['主卧', '浴室', '衣柜'], ['次卧'], ['儿童房'], ['书房'], ['阳台', '天气', '日照', '太阳', '室外'], ['其它']]
domain_names = ['', '天气', '日照', '太阳', '传感器', '二元传感器', '人员',  '设备', '灯光', '开关', '风扇', '净化器', '新风机', '扫地机', '卷帘', '空调', '地暖', '视听', '摄像头', '输入', '遥控', '智能', '隐藏', '其它']
domain_types = ['weather', 'sun', 'sensor', 'binary_sensor', 'person', 'device_tracker', 'light', 'switch',
                'fan', 'remote', 'vacuum', 'cover', 'climate', 'media_player', 'camera', 'input_text', 'automation']
type_names = {'device_tracker': '设备', 'input_text': '输入', 'person': '人员'}
name_types = {'净化': '净化器',  '新风': '新风机', '扇': '风扇', '音箱': '视听', '存储': '视听', '幕布': '视听', '帘': '卷帘'}


def get_zone(name, default=None):
    for i in zone_names:
        for zone in i:
            if name.startswith(zone):
                return i[0]
    return None


def get_zone_index(name):
    for i in range(len(zone_names)):
        for zone in zone_names[i]:
            if name.startswith(zone):
                return i
    return -1


def get_entity_zone(attributes, default=None):
    for key in ['genie_zone', 'genie_name', 'friendly_name']:
        if key in attributes:
            zone = get_zone(attributes[key])
            if zone is not None:
                return zone
    return default


def get_entity_zone_index(attributes):
    for key in ['genie_zone', 'genie_name', 'friendly_name']:
        if key in attributes:
            index = get_zone_index(attributes[key])
            if index != -1:
                return index
    return -1


def add_to_sorted(items, item, compare):
    i = len(items) - 1
    while i >= 0 and compare(items[i], item) > 0:
        i -= 1
    items.insert(i + 1, item)


def compare_item(items, item1, item2):
    try:
        index1 = items.index(item1)
    except:
        index1 = 65535
    try:
        index2 = items.index(item2)
    except:
        index2 = 65535
    return index1 - index2


def compare_name(name1, name2):
    string1 = slugify(name1)
    string2 = slugify(name2)
    if string1 < string2:
        return -1
    elif string1 > string2:
        return 1
    return 0


def compare_title(title1, title2):
    ret = get_zone_index(title1) - get_zone_index(title2)
    if ret == 0:
        ret = compare_item(domain_names, title1, title2)
        if ret == 0:
            ret = compare_name(title1, title2)
    return ret


entity_attributes = {}


def compare_entity(entity_id1, entity_id2):
    domain1 = entity_id1[:entity_id1.find('.')]
    domain2 = entity_id2[:entity_id2.find('.')]
    ret = compare_item(domain_types, domain1, domain2)
    if ret == 0:
        attrs1 = entity_attributes[entity_id1]
        attrs2 = entity_attributes[entity_id2]
        ret = get_entity_zone_index(attrs1) - get_entity_zone_index(attrs2)
        if ret == 0:
            if domain1 == 'sensor':
                ret = compare_item(sensor_units, attrs1.get('unit_of_measurement'), attrs2.get('unit_of_measurement'))
            elif domain1 == 'binary_sensor':
                ret = compare_item(binary_sensor_classes, attrs1.get('device_class'), attrs2.get('device_class'))
            if ret == 0:
                ret = compare_name(attrs1['friendly_name'], attrs2['friendly_name'])
    return ret


def compare_card(card1, card2):
    ret = compare_item(card_types, card1['type'], card2['type'])
    if ret == 0:
        title1 = card1.get('title') or card1.get('name', '')
        title2 = card2.get('title') or card2.get('name', '')
        ret = compare_title(title1, title2)
        if ret == 0:
            entity_id1 = card1.get('entity')
            entity_id2 = card2.get('entity')
            if entity_id1:
                if entity_id2:
                    return compare_entity(entity_id1, entity_id2)
                else:
                    return -1
            elif entity_id2:
                return 1
    return ret


add_to_entities = partial(add_to_sorted, compare=compare_entity)
add_to_cards = partial(add_to_sorted, compare=compare_card)
add_to_views = partial(add_to_sorted, compare=lambda x, y: compare_title(x['title'], y['title']))


def add_to_entities_card(cards, title, entity_id, key='title', type='entities'):
    card = next((i for i in cards if i.get(key) == title), None)
    if card is None:
        add_to_cards(cards, {'type': type, key: title, 'entities': [entity_id]})
    else:
        add_to_entities(card['entities'], entity_id)


add_to_glance_card = partial(add_to_entities_card, key='name', type='glance')


def make_card(entity_id, card_type):
    return {'type': card_type, 'entity': entity_id}


def make_weather_card(entity_id, name, attributes):
    card = {'type': 'weather-forecast', 'name': name, 'entity': entity_id}
    if 'attribution' in attributes:
        card['secondary_info_attribute'] = 'attribution'
    return card


def make_lovelace(hass, views, handle_entity):
    title = '智家'
    entities = hass.states.async_all()
    for i in entities:
        entity_id = i.entity_id
        attributes = i.attributes
        name = attributes['friendly_name']
        if entity_id == 'zone.home':
            title = name
            continue
        entity_attributes[entity_id] = attributes
        domain = entity_id[:entity_id.find('.')]
        handle_entity(domain, entity_id, name, attributes)
    return {'title': title, 'views': views}


def make_zone_lovelace(hass):
    views = []

    def handle_entity(domain, entity_id, name, attributes):
        zone = '其它' if 'hidden' in attributes else get_entity_zone(attributes, '其它')
        view = next((i for i in views if i.get('title') == zone), None)
        if view is None:
            view = {'title': zone, 'path': slugify(zone), 'badges': [], 'cards': []}
            add_to_views(views, view)
        cards = view['cards']
        if 'hidden' in attributes:
            return add_to_entities_card(cards, '隐藏', entity_id)
        if domain in ['sun', 'sensor', 'binary_sensor', 'person', 'device_tracker']:
            return add_to_entities(view['badges'], entity_id)
        elif domain == 'weather':
            card = make_weather_card(entity_id, name, attributes)
        elif domain == 'media_player':
            card = make_card(entity_id, 'media-control')
        elif domain == 'climate':
            card = make_card(entity_id, 'thermostat')
        elif domain == 'camera':
            card = make_card(entity_id, 'picture-entity')
        elif domain == 'automation':
            return add_to_entities_card(cards, '智能', entity_id)
        else:
            return add_to_entities_card(cards, '', entity_id)
        add_to_cards(cards, card)

    return make_lovelace(hass, views, handle_entity)


def make_type_lovelace(hass):
    status_cards = []
    toggle_cards = []
    thermostat_cards = []
    guard_cards = []
    guard_badges = []
    automation_cards = []
    other_cards = []
    local_names = locals()
    tabs = [('状态', 'status'), ('调控', 'toggle'), ('空调', 'thermostat'), ('安防', 'guard'), ('智能', 'automation'), ('其它', 'other')]
    views = [{'title': i[0], 'path': i[1], 'cards': local_names[i[1] + '_cards']} for i in tabs]
    views[3]['badges'] = guard_badges

    def handle_entity(domain, entity_id, name, attributes):
        if 'hidden' in attributes:
            add_to_entities_card(other_cards, '隐藏', entity_id)
        elif domain == 'weather':
            add_to_cards(status_cards, make_weather_card(entity_id, name, attributes))
        elif domain == 'sun' or domain == 'sensor':
            add_to_glance_card(status_cards, get_entity_zone(attributes, '其它'), entity_id)
        elif domain == 'binary_sensor':
            add_to_entities(guard_badges, entity_id)
        elif domain == 'light':
            add_to_entities_card(toggle_cards, '灯光', entity_id)
        elif domain == 'media_player':
            add_to_entities_card(toggle_cards, '视听', entity_id)
        elif domain == 'cover' or domain == 'fan' or domain == 'switch' or domain == 'vacuum':
            add_to_entities_card(toggle_cards, next((v for k, v in name_types.items() if k in name), '其它'), entity_id)
        elif domain == 'climate':
            add_to_cards(thermostat_cards, make_card(entity_id, 'thermostat'))
        elif domain == 'camera':
            add_to_cards(guard_cards, make_card(entity_id, 'picture-entity'))
        elif domain == 'automation':
            add_to_entities_card(automation_cards, get_entity_zone(attributes, '其它'), entity_id)
        else:
            add_to_entities_card(other_cards, type_names.get(domain, '其它'), entity_id)

    lovelace = make_lovelace(hass, views, handle_entity)
    merge_single_card(views)
    return lovelace


def merge_single_card(views):
    for view in views:
        cards = view['cards']
        for card in cards:
            card_type = card['type']
            if card_type == 'entities':
                card_key = 'title'
            elif card_type == 'glance':
                card_key = 'name'
            else:
                continue
            if card[card_key] != '其它':
                entities = card['entities']
                if len(entities) == 1:
                    add_to_entities_card(cards, '其它', entities[0], card_key, card_type)
                    cards.remove(card)


def setup(hass, config):
    def lovelace_updated(event):
        url_path = event if isinstance(event, str) else event.data.get('url_path')
        if url_path == 'zhilace-type':
            data = make_type_lovelace(hass)
        elif url_path == 'zhilace-zone':
            data = make_zone_lovelace(hass)
        else:
            return
        path = hass.config.path(url_path + '.yaml')
        if (not os.path.exists(path)) if isinstance(event, str) else (load_yaml(path) != data):
            save_yaml(path, data)

    def homeassistant_start(event):
        for url_path in ['zhilace-type', 'zhilace-zone']:
            lovelace_updated(url_path)
        hass.bus.listen('lovelace_updated', lovelace_updated)

    hass.bus.listen('homeassistant_start', homeassistant_start)
    return True
