FROM jupyter/all-spark-notebook

LABEL maintainer="Filippo Squillace <feel.sqoox@gmail.com>"

USER $NB_UID

# List of all packages/extensions installed:
#
# Jupyter contrib extensions:
# https://github.com/ipython-contrib/jupyter_contrib_nbextensions
# Qgrid:
# https://github.com/quantopian/qgrid
# DGL: Deep learning on graphs
# https://www.dgl.ai/pages/start.html
# Imbalanced learn: Data augmentation. Allows to under-sampling/over-sampling data.
# https://imbalanced-learn.readthedocs.io/en/stable/
# SHAP: Explains why the output of any ML model by analyzing the trained model
# https://github.com/slundberg/shap
# Install vim-binding which does not have a pip or conda package at the moment
# https://github.com/lambdalisue/jupyter-vim-binding
# Vim for JupyterLab:
# https://github.com/jwkvam/jupyterlab-vim
# TOC:
# https://github.com/jupyterlab/jupyterlab-toc
# DrawIO:
# https://github.com/QuantStack/jupyterlab-drawio
# Qgrid:
# https://github.com/quantopian/qgrid
# ipysheet:
# https://github.com/QuantStack/ipysheet
# GitHub:
# https://github.com/jupyterlab/jupyterlab-github
# GluonCV: a Deep Learning Toolkit for Computer Vision
# https://gluon-cv.mxnet.io/
# GluonNLP: NLP made easy
# https://gluon-nlp.mxnet.io/
# GluonTS: Probabilistic Time Series Modeling
# https://gluon-ts.mxnet.io/
# XGBoost: Advanced regressor and classifier
# https://xgboost.ai/
# Markdown-kernel:
# https://github.com/vatlab/markdown-kernel
# NLTK: human language data for the purpose of building chatbots
# https://www.nltk.org/
# Keras: Deep learning and neural networks
# https://keras.io/
# Tensorflow: Neural network builder
# https://www.tensorflow.org/
# JobLib:
# https://joblib.readthedocs.io/en/latest/

# Custom pip packages
RUN pip install --upgrade pip && \
    pip install --no-cache-dir \
    mxnet gluoncv gluonts gluonnlp \
    xgboost \
    s3contents \
    jupyterlab_github \
    nltk \
    keras \
    tensorflow \
    joblib \
    markdown-kernel && \
    python -m markdown_kernel.install

# Custom packages via conda
RUN conda install --quiet --yes \
    'pymc3' qgrid && \
    conda install --quiet --yes -c conda-forge \
    'jupyter_contrib_nbextensions' \
    'ipysheet' \
    'shap' \
    'imbalanced-learn' \
    'jupytext' && \
    jupyter nbextensions_configurator enable --user && \
    conda install --quiet --yes -c dglteam dgl && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Custom extensions
RUN mkdir -p /home/$NB_USER/.local/share/jupyter/nbextensions && \
    cd /home/$NB_USER/.local/share/jupyter/nbextensions && \
    git clone https://github.com/lambdalisue/jupyter-vim-binding vim_binding && \
    chmod -R go-w vim_binding && \
    jupyter labextension install ipysheet && \
    jupyter labextension install jupyterlab_vim && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install jupyterlab-drawio && \
    jupyter labextension install qgrid && \
    jupyter labextension install @jupyterlab/github && \
    jupyter labextension install @jupyterlab/plotly-extension && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Almond
# https://almond.sh/
# Images available: https://github.com/almond-sh/docker-images

USER root

RUN curl -L -o /usr/local/bin/coursier https://git.io/coursier-cli && \
    chmod +x /usr/local/bin/coursier

USER $NB_UID

# ensure the JAR of the CLI is in the coursier cache, in the image
RUN /usr/local/bin/coursier --help

ENV SCALA_VERSION=2.12.8 \
    ALMOND_VERSION=0.6.0

RUN coursier bootstrap \
      -r jitpack \
      -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
      sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
      --default=true --sources \
      -o almond && \
    ./almond --install --log info --metabrowse && \
    rm almond


