#!/bin/env python3

from pathlib import Path
import subprocess
import sys
import os
import stat
import shutil
import numpy as np

POWERDEVS_HOME = Path(os.getenv('POWERDEVS_HOME','../../powerdevs/'))

default_tf = 200000
parameters = {'tc': {'start': 23.2, 'stop': 25, 'step':0.2, 'tf':20000000, 'output_file':'Qm.csv'}}

def get_environment():
    
    pdppt_path = POWERDEVS_HOME / 'bin' / 'pdppt'
    if not Path.exists(pdppt_path):
        print(f'No se puede acceder a pdppt en: {pdppt_path}')    
        sys.exit()

    os.environ['LD_LIBRARY_PATH'] = str(POWERDEVS_HOME / 'bin')

    return pdppt_path


def compilation(source):
         
    if not Path.exists(source):
        print(f'No se puede acceder al model en: {source}')
        sys.exit()

    target = Path(POWERDEVS_HOME / 'output' / 'model')
    
    if not Path(target).exists() or (os.stat(source)[stat.ST_MTIME] > os.stat(target)[stat.ST_MTIME]):
        subprocess.run([pdppt, '-m', source])

    return target

if __name__ == '__main__':
    pdppt = get_environment()

    model_path = Path(__file__).parent / '..' / 'circadiano.pdm'
    compiled = compilation(model_path)    
    model_params = Path(compiled).parent / 'model.params'

    for parameter, values in parameters.items():
        start = values['start']
        stop = values['stop']
        step = values['step']
        tf = values.get('tf',default_tf)
        output_file = values['output_file']
        
        print(f"Simulando {parameter} desde {start} -> {stop} ({step}) ..")
        for value in np.arange(start,stop,step):
            print(f'{parameter}:{value:.3f}')
            subprocess.run([compiled, '--c', str(model_params),
                            '-tf', str(tf), 
                            f'-{parameter}', str(value)])
            
            output_file_param = f'{Path(output_file).stem}-{parameter}{value:.3f}{Path(output_file).suffix}'
            print(f'Salida en: {output_file_param}')
            shutil.move(output_file, output_file_param)
            # INSERTAR INVOCACION A PROCESAMIENTO DE RESULTADO CON R


    
    
